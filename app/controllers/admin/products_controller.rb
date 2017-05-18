class Admin::ProductsController < Admin::ApplicationController
  layout 'admin_dashboard'
  include Mixins::ProductHelper

  def index
    status_actions
    @products = Product.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def edit
    status_actions
    set_product
    edit_product
  end

  def new
    new_product
  end

  def create
    create_product
  end

  def update
    update_product
  end

  private

  def after_create_and_update_path
    if params[:button] == 'new'
      path = new_admin_product_path
    elsif params[:button] == 'edit'
      path = edit_admin_product_path(@product)
    else
      path = admin_products_path
    end
  end

  def parse_categories categories
    sub_categories = []

    categories.each do |category|
      sub_categories << { category_id: category }
    end

    sub_categories
  end

  def parse_pricebrakes pricebreaks
    sub_pricebreaks = []

    pricebreaks.each do |pricebreak|
      sub_pricebreaks << pricebreak
    end

    sub_pricebreaks
  end

  def status_actions
    @status_actions = [
      ['', ''],
      ['Futured', 'futured'],
      ['Recommended', 'recommended'],
      ['Best', 'best']
    ]
  end
end
