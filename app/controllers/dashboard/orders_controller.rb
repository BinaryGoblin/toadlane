class Dashboard::OrdersController < DashboardController
  # before_action :get_order_status, only: [:index]

  def index
    case params[:type]
    when 'armor'
      @orders = current_user.armor_orders(params[:bought_or_sold]).for_dashboard(params[:page], params[:per_page])
    when 'stripe'
      @orders = current_user.stripe_orders(params[:bought_or_sold]).for_dashboard(params[:page], params[:per_page])
    when 'green'
      @orders = current_user.green_orders(params[:bought_or_sold]).for_dashboard(params[:page], params[:per_page])
    else
      @orders = current_user.stripe_orders(params[:bought_or_sold]).for_dashboard(params[:page], params[:per_page])
    end
  end
  
  def show
    case params[:type]
    when 'stripe'
      @order = StripeOrder.find(params[:id])
    when 'armor'
      @order = ArmorOrder.find(params[:id])
    when 'green'
      @order = GreenOrder.find(params[:id])
    else
      @order = StripeOrder.find(params[:id])
    end
  end

  def delete_cascade
    if params[:orders_ids].present?
      params[:orders_ids].each do |id|
        ArmorOrder.find(id).update(deleted: true)
      end
    end

    render json: :ok
  end

  def cancel_order
    if params[:id].present?
      case params[:type]
      when 'stripe'
        order = StripeOrder.find(params[:id])
      when 'armor'
        order = ArmorOrder.find(params[:id])
      when 'green'
        order = GreenOrder.find(params[:id])
      else
        order = StripeOrder.find(params[:id])
      end
      if order.present?
        response = order.check_status
        if response['Result'] == '0'
          if response['Processed'] == 'True'
            if order.refund_request.nil?
              refund_request = RefundRequest.new(buyer_id: order.buyer_id, seller_id: order.seller_id)
              order.refund_request = refund_request
              order.challenged!
              flash[:notice] = "Refund Request has been created. ##{refund_request.id}"
            end
          else
            cancellation_response = order.check_cancel
            if cancellation_response['Result'] == '0'
              order.cancel_order
              flash[:notice] = "The order has been canceled."
            else
              flash[:alert] = "Cancellation Response: #{response['ResultDescription']}"
            end
          end 
        else
          flash[:alert] = "GreenByPhone Response: #{response['ResultDescription']}"
        end
      end
    end
  end

  private
   def get_order_status
    @orders = ArmorOrder.where(deleted: false).own_orders(current_user.id)
    if @orders.any?
      client = ArmorService.new

      @orders.each do |order|
        begin
          result = client.orders(current_user.armor_account_id).get(order.order_id)
        rescue
        ensure
          order.update(status: result.data[:body]['status'].to_i) if result
        end
      end
    end
   end
end
