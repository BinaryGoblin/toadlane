class Dashboard::OrdersController < DashboardController
  # before_action :get_order_status, only: [:index]

  def index
    orders = []
    fly_buy_orders = current_user.fly_buy_orders.not_deleted
    stripe_orders = current_user.stripe_orders.for_dashboard(params[:page], params[:per_page])
    green_orders = current_user.green_orders.for_dashboard(params[:page], params[:per_page])
    amg_orders = current_user.amg_orders.for_dashboard(params[:page], params[:per_page])
    emb_orders = current_user.emb_orders.for_dashboard(params[:page], params[:per_page])

    current_user_involved_groups = Group.joins(:group_sellers).where(
                                          'group_sellers.user_id' => current_user.id)

    current_user_involved_orders = FlyBuyOrder.where(group_seller_id: current_user_involved_groups.ids).where.not(count: nil, status: nil)

    orders =  fly_buy_orders + stripe_orders + green_orders + amg_orders + emb_orders + current_user_involved_orders

    @orders = orders.sort_by(&:created_at).reverse
    @fee = Fee.find_by(:module_name => "Fly & Buy").value
  end

  def show
    case params[:type]
    when 'armor'
      @order = ArmorOrder.find(params[:id])
    when 'green'
      @order = GreenOrder.find(params[:id])
    when 'amg'
      @order = AmgOrder.find(params[:id])
    when 'emb'
      @order = EmbOrder.find(params[:id])
    when 'fly_buy'
      @fee = Fee.find_by(:module_name => "Fly & Buy").value
      @order = FlyBuyOrder.find(params[:id])
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
        when 'FlyBuyOrder'
          @order = FlyBuyOrder.find(order_id).update(deleted: true)
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

  def request_new_inspection_date
    inspection_date = DateTime.new(
      params["inspection_date"]["date(1i)"].to_i,
      params["inspection_date"]["date(2i)"].to_i,
      params["inspection_date"]["date(3i)"].to_i,
      params["inspection_date"]["date(4i)"].to_i,
      params["inspection_date"]["date(5i)"].to_i
    )

    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    fbo_inspection_date = fly_buy_order.inspection_dates.first
    if current_user == fly_buy_order.buyer
      creator_type = Product::BUYER
      responder = Product::SELLER
      receiver = fly_buy_order.seller
      sender = fly_buy_order.buyer
    elsif current_user == fly_buy_order.seller
      creator_type = Product::SELLER
      responder = Product::BUYER
      receiver = fly_buy_order.buyer
      sender = fly_buy_order.seller
    end
    fbo_inspection_date.update_attributes({
      new_requested_date: inspection_date,
      creator_type: creator_type,
      approved: false
    })
    new_inspection_date_notification(fly_buy_order, receiver, sender)
    flash[:notice] = "Your requested inspection date has been submitted. You will be notified when the #{responder} responds."
    redirect_to dashboard_orders_path
  end

  def approve_new_inspection_date
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    fbo_inspection_date = fly_buy_order.inspection_dates.first
    fbo_inspection_date.update_attributes({
      date: fbo_inspection_date.new_requested_date,
      approved: true
    })

    if fbo_inspection_date.creator_type == "seller"
      receiver = fly_buy_order.seller
    elsif fbo_inspection_date.creator_type == "buyer"
      receiver = fly_buy_order.buyer
    end

    flash[:notice] = "You have accepted requested inspection date."
    UserMailer.send_new_inspection_date_approved_notification(fly_buy_order, receiver, current_user).deliver_later
    UserMailer.order_inspection_date_change_notification_to_admin(fly_buy_order, current_user).deliver_later
    redirect_to dashboard_orders_path
  end

  private

  def new_inspection_date_notification(order, receiver, sender)
    UserMailer.send_new_inspection_date_requested_notification(order, receiver, sender).deliver_later
    UserMailer.order_inspection_date_change_notification_to_admin(order, sender).deliver_later
  end
end
