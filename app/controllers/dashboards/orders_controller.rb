class Dashboards::OrdersController < ::DashboardsController
  # before_action :get_order_status, only: [:index]

  def index
    if params[:type_order] == 'buy'
      @orders = ArmorOrder.orders_for_buy(current_user.id).order('created_at DESC').paginate(page: params[:page], per_page: params[:count])
    elsif params[:type_order] == 'sell'
      @orders = ArmorOrder.orders_for_sell(current_user.id).order('created_at DESC').paginate(page: params[:page], per_page: params[:count])
    else
      @orders = ArmorOrder.where(deleted: false).own_orders(current_user.id).order('created_at DESC').paginate(page: params[:page], per_page: params[:count])
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

  private
   def get_order_status
    @orders = ArmorOrder.where(deleted: false).own_orders(current_user.id)
    if @orders.any?
      data = ArmorService.new

      @orders.each do |order|
        result = data.get_order_status({
          'account' => current_user.armor_profile.armor_account,
          'order_id' => order.order_id
        })
        if result
          order.update(status: result.to_i)
        end
      end
    end
   end
end
