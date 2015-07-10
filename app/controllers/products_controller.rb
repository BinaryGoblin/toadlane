class ProductsController < ApplicationController
  layout 'user_dashboard'

  before_action :set_product, only: [:show]

  before_filter :authenticate_user!, except: [:index]
  before_action :check_terms_of_service

  def index
    if current_user.present?
      @products_recommended = Product.unexpired.where(status_action: 'recommended').order(:created_at).limit(16)
      @products_best = Product.unexpired.where(status_action: 'best').order(:created_at).limit(16)
      @products_new_deals = Product.unexpired.order(:created_at).limit(16)
      @featured_sellers = User.limit(16)
    else
      redirect_to root_path
    end
  end

  def show
    @related_products = Product.unexpired.where(main_category: @product.main_category).where.not(id: @product.id)
  end

  def products
    @products = Product.unexpired.order('updated_at DESC').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def offers
    @products = Product.unexpired.where(status_characteristic: 'sell').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end

  def deals
# TODO
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end
end
