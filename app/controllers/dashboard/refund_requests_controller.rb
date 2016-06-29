class Dashboard::RefundRequestsController < DashboardController
  def index
    @refund_requests = current_user.refund_requests(params[:bought_or_sold]).for_dashboard(params[:page], params[:per_page])
    # TODO: the order could be of other types later
    @refund_requested_orders = @refund_requests.collect{|rr| rr.green_order }
  end

  def accept_refund
    refund_request = RefundRequest.find(params[:id])
    if refund_request.present?
      response = refund_request.refund
      if response['Result'] == '0'
        refund_request.accepted!
        refund_request.green_order.refunded!
        render json: :ok
      else
        render json: :ok, alert: "GreenByPhone Response: #{response['ResultDescription']}"
      end
    else
      render json: :ok, alert: "Refund Request not found."
    end
  end

  def reject_refund
    refund_request = RefundRequest.find(params[:id])
    if refund_request.present?
      refund_request.rejected!
      refund_request.green_order.placed!
    end
    render json: :ok
  end

  def cancel_refund
    refund_request = RefundRequest.find(params[:id])
    if refund_request.present?
      refund_request.green_order.placed!
      refund_request.update_attributes({ deleted: true, green_order_id: nil })
    end
    render json: :ok
  end
end