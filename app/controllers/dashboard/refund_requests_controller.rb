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
        refund_request.green_order.cancel_order
        flash[:notice] = "Refund Request has been successfully accepted."
      else
        flash[:alert] = "GreenByPhone Response: #{response['ResultDescription']}"
      end
    else
      flash[:alert] = "Refund Request not found."
    end
    respond_to do |format|
      format.js { render :template => 'shared/update_flash' }
    end
  end

  def reject_refund
    refund_request = RefundRequest.find(params[:id])
    if refund_request.present?
      refund_request.rejected!
      refund_request.green_order.placed!
      flash[:notice] = "Refund Request has been rejected."
    end
    respond_to do |format|
      format.js { render :template => 'shared/update_flash' }
    end
  end

  def cancel_refund
    refund_request = RefundRequest.find(params[:id])
    if refund_request.present?
      refund_request.green_order.placed!
      refund_request.update_attributes({ deleted: true, green_order_id: nil })
      flash[:notice] = "Refund Request has been been canceled."
    end
    respond_to do |format|
      format.js { render :template => 'shared/update_flash' }
    end
  end
end