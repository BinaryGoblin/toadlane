class Admin::ProductsController < Admin::ApplicationController
  layout 'admin_dashboard'

  before_action :set_product, only: [:update]

  def index
    @status_actions = [
      ['Futured', 'futured'],
      ['Recomended', 'recomended'],
      ['Best', 'best']
    ]
    @products = Product.unscoped.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.json { head :no_content }
      else
        format.html { render action: 'index' }
      end
    end
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:status_action)
    end
end
