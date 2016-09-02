class Dashboard::OrdersController < DashboardController
  # before_action :get_order_status, only: [:index]

  def index
    orders = []
    promise_orders = current_user.promise_orders.with_promise_item_id
    stripe_orders = current_user.stripe_orders.for_dashboard(params[:page], params[:per_page])
    green_orders = current_user.green_orders.for_dashboard(params[:page], params[:per_page])
    amg_orders = current_user.amg_orders.for_dashboard(params[:page], params[:per_page])
    emb_orders = current_user.emb_orders.for_dashboard(params[:page], params[:per_page])

    orders =  promise_orders + stripe_orders + green_orders + amg_orders + emb_orders

    @orders = orders.sort_by(&:created_at).reverse
  end

  def show
    case params[:type]
    when 'stripe'
      @order = StripeOrder.find(params[:id])
    when 'armor'
      @order = ArmorOrder.find(params[:id])
    when 'green'
      @order = GreenOrder.find(params[:id])
    when 'amg'
      @order = AmgOrder.find(params[:id])
    when 'emb'
      @order = EmbOrder.find(params[:id])
    when 'promise'
      @order = PromiseOrder.find(params[:id])
    else
      @order = StripeOrder.find(params[:id])
    end
  end

  def delete_cascade
    if params["order_details"].present?
      params["order_details"].each do |order_detail|
        splited_order_detail = order_detail.split(",")
        order_id = splited_order_detail.first
        order_type = splited_order_detail.second
        case order_type
        when 'StripeOrder'
          @order = StripeOrder.find(order_id).update(deleted: true)
        when 'ArmorOrder'
          @order = ArmorOrder.find(order_id).update(deleted: true)
        when 'GreenOrder'
          @order = GreenOrder.find(order_id).update(deleted: true)
        when 'AmgOrder'
          @order = AmgOrder.find(order_id).update(deleted: true)
        when 'EmbOrder'
          @order = EmbOrder.find(order_id).update(deleted: true)
        else
          @order = StripeOrder.find(order_id).update(deleted: true)
        end
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
      when 'amg'
        order = AmgOrder.find(params[:id])
      when 'emb'
        order = EmbOrder.find(params[:id])
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
              UserMailer.refund_request_notification_to_seller(order).deliver_now
              flash[:notice] = "Refund Request has been created. ##{refund_request.id}"
            end
          else
            cancellation_response = order.check_cancel
            if cancellation_response['Result'] == '0'
              order.cancel_order
              UserMailer.order_canceled_notification_to_seller(order).deliver_now
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
    respond_to do |format|
      format.js { render :template => 'shared/update_flash' }
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
