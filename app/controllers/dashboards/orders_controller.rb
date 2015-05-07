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
