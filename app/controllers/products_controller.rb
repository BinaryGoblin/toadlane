class ProductsController < ApplicationController

  # impressionist is for allowing view count and ease of it
  impressionist :actions=>[:show],  :unique => [:user_id]

  layout 'user_dashboard'

  before_action :check_terms_of_service

  def index
    # TODO Disabling this during Stripe integration by calling for 'buy' only
    @products_recommended = Product.unexpired.where(status_characteristic: 'sell', status_action: 'recommended').order(created_at: :desc).limit(16)
    @products_for_sale = Product.unexpired.where(status_characteristic: 'sell').order(created_at: :desc).limit(16)
    @products_ending_soon = Product.unexpired.where(status_characteristic: 'sell').order(end_date: :asc).limit(16)
    # TODO Disabling this during Stripe integration by calling for 'buy' instead of 'sell'
    # @products_requested = Product.unexpired.where(status_characteristic: 'sell').order(created_at: :desc).limit(16)
    @featured_sellers = User.limit(16)
  end

  def show
    if current_user.present? && !current_user.profile_complete?
      redirect_to dashboard_profile_path, :flash => { :error => "You must complete your profile before you can view product details." }
      return
    end
    set_product
    @stripe_order = StripeOrder.new
    @fee = Fee.find_by(:module_name => "Stripe").value
    commontator_thread_show(@product)
    @related_products = Product.unexpired.where(main_category: @product.main_category).where.not(id: @product.id)

    @armor_order = ArmorOrder.find_by_id(params[:armor_order_id]) if params[:armor_order_id].present?
  end

  def products
    @products = Product.unexpired.where(status_characteristic: 'sell').order('updated_at DESC').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def deals
    # TODO
  end

  def for_sale
    @products = Product.unexpired.where(status_characteristic: 'sell').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end

  def requested
    # TODO Disabling this during Stripe integration by calling for 'buy' instead of 'sell'
    @products = Product.unexpired.where(status_characteristic: 'buy').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end

  # TODO Refactor 10018
  def checkout
    return unless current_user.present?
    @product = Product.find(params[:product_id])
    @data = {
      total: params[:total],
      quantity: params[:count],
      fee_amount: params[:fee],
      shipping_cost: params[:shipping_cost],
      rebate: params[:rebate],
      rebate_percent: params[:rebate_percent],
      available_product: @product.remaining_amount,
      fee: Fee.find_by(:module_name => "Stripe").value
    }

    @stripe_order = StripeOrder.new
    @green_order = GreenOrder.new

    if params["armor_order_id"].present? && params["inspection_date"].present? && params["inspection_date"]["inspection_date_id"].present?
      @armor_order = ArmorOrder.find_by_id(params["armor_order_id"])
      @armor_order.update_attributes({
        unit_price: @product.unit_price,
        count: params[:count],
        amount: params[:total],
        summary: @product.name,
        description: @product.description,
        rebate_price: params[:rebate],
        rebate_percent: params[:rebate_percent],
        fee: params[:fee], # this is fee amount
        rebate: params[:rebate_percent],
        shipping_cost: params[:shipping_cost]
      })
      inspection_date = InspectionDate.find_by_id(params["inspection_date"]["inspection_date_id"])
      inspection_date.update_attributes({armor_order_id: @armor_order.id, approved: true})
    elsif params["inspection_date"].present? && params["inspection_date"]["inspection_date_id"].present?
      @armor_order = ArmorOrder.create({
        buyer_id: current_user.id,
        seller_id: @product.user.id,
        product_id: @product.id,
        unit_price: @product.unit_price,
        count: params[:count],
        amount: params[:total],
        summary: @product.name,
        description: @product.description,
        rebate_price: params[:rebate],
        rebate_percent: params[:rebate_percent],
        fee: params[:fee], # this is fee amount
        rebate: params[:rebate_percent],
        shipping_cost: params[:shipping_cost]
      })
      inspection_date = InspectionDate.find_by_id(params["inspection_date"]["inspection_date_id"])
      inspection_date.update_attributes({armor_order_id: @armor_order.id, approved: true})
    elsif params["armor_order_id"].present?
      @armor_order = ArmorOrder.find_by_id(params["armor_order_id"])
    else
      @armor_order = ArmorOrder.new
    end

    @armor_profile = current_user.armor_profile.present? ? current_user.armor_profile : ArmorProfile.new
    @amg_order = AmgOrder.new
  end

  def subregion_options
    render partial: 'subregion_select'
  end

  def get_certificate
    certificate = Certificate.find(params[:certificate_id])
    send_data certificate.data, :filename => certificate.filename, :type => certificate.content_type
  end

  private
  def set_product
    @product = Product.find(params[:id])
    if @product.default_payment.nil?
      @product.update_attribute(:default_payment, @product.available_payments.first)
    end
  end

  def set_order_details(armor_order, data)
    armor_order.rebate_percentage = data[:rebate_percent]
    armor_order.quantity = data[:quantity]
    armor_order.order_amount = data[:total]
    armor_order.rebate = data[:rebate]
    armor_order.fee_percent = data[:fee]
    armor_order.fee_price = data[:fee_amount]
    armor_order.shipping_cost = data[:shipping_cost]
  end
end
