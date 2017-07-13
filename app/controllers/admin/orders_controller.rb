class Admin::OrdersController < Admin::ApplicationController
  layout 'admin_dashboard'

  before_action :set_product, only: [:update]

  def index
    stripe_order = StripeOrder.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    fly_buy_order = FlyBuyOrder.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @orders = fly_buy_order + stripe_order
    puts @orders.inspect
  end

  def update
    respond_to do |format|
      if @order.update(product_params)
        format.json { head :no_content }
      else
        format.html { render action: 'index' }
      end
    end
  end

  private
    def set_order
      @product = ArmorOrder.find(params[:id])
    end

    def order_params
      params.require(:armor_order)
    end
end