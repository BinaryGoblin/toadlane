class ProductsController < ApplicationController
  layout 'user_dashboard'

  before_action :set_product, only: [:show]

  before_filter :authenticate_user!, except: [:index]

  def index
    if current_user.present?
      @products_recomended = Product.recomended
      @products_best = Product.best
      @products_new_deals = Product.new_deals
      @featured_sellers = User.featured
    else
      redirect_to root_path
    end
  end

  def show
    @related_products = Product.related_products_by_main_category @product.id
  end

  def products
    @products = Product.all_products.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end
 
  def offers
    @products = Product.where(status_characteristic: 'sell').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end

  def deals
# TODO
  end

  private
    def set_product
      @product = Product.unscoped.find(params[:id])
    end
end
