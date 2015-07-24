class ProductsController < ApplicationController
  layout 'user_dashboard'

  before_action :set_product, only: [:show]

  before_filter :authenticate_user!, except: [:index, :products, :show, :for_sale, :requested]
  before_action :check_terms_of_service

  def index
    @products_recommended = Product.unexpired.where(status_action: 'recommended').order(:created_at).limit(16)
    @products_for_sale = Product.unexpired.where(status_characteristic: 'sell').order(:created_at).limit(16)
    @products_requested = Product.unexpired.where(status_characteristic: 'buy').order(:created_at).limit(16)
    @featured_sellers = User.limit(16)
  end

  def show
    @related_products = Product.unexpired.where(main_category: @product.main_category).where.not(id: @product.id)
  end

  def products
    @products = Product.unexpired.order('updated_at DESC').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def deals
# TODO
  end
  
  def for_sale
    @products = Product.unexpired.where(status_characteristic: 'sell').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end
  
  def requested
    @products = Product.unexpired.where(status_characteristic: 'buy').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end
end
