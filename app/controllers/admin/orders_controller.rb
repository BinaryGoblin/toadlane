class Admin::OrdersController < Admin::ApplicationController
  layout 'admin_dashboard'

  before_action :set_product, only: [:update]

  def index
    @orders = ArmorOrder.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
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