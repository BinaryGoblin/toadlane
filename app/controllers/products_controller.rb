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
    # if current_user.present? && !current_user.profile_complete?
    #   redirect_to dashboard_profile_path, :flash => { :error => "You must complete your profile before you can view product details." }
    #   return
    # end
    set_product
    @stripe_order = StripeOrder.new
    @fee = Fee.find_by(:module_name => "Stripe").value
    commontator_thread_show(@product)
    @related_products = Product.unexpired.where(main_category: @product.main_category).where.not(id: @product.id)

    if params[:promise_order_id].present?
      @promise_order = PromiseOrder.find_by_id(params[:promise_order_id])
    else
      @promise_order = PromiseOrder.new
    end
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
    @product = Product.find(params[:product_id])
    if current_user.present? && !current_user.profile_complete?
      redirect_to product_path(@product), :flash => { :error => "You must complete your profile before you can view product details." }
    end

    response.headers["X-FRAME-OPTIONS"] = "SAMEORIGIN"

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

    @promise_order, @promise_account = promise_order_process(@product)

    @stripe_order = StripeOrder.new
    @green_order = GreenOrder.new

    @emb_order = EmbOrder.new
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

  def calculate_armor_payments_fee(armor_order, amount)
    # here amount is unit_price * count
    if amount > 1000000
      armor_fee = 6400 + ((amount-1000000)*0.0035)
    elsif amount > 500000
      armor_fee = 3900 + ((amount-500000)*0.005)
    elsif amount > 50000
      armor_fee = 525 + ((amount-50000)*0.0075)
    elsif amount > 5000
      armor_fee = 75 + ((amount-5000)*0.01)
    else
      armor_fee = [10, amount*0.015].max
    end
  end

  # This is done just for displaying to the seller
  # # Armor will charge in their backend
  def calculate_store_additional_armor_fee(armor_order)
    amount = armor_order.unit_price * armor_order.count

    armor_fee = calculate_armor_payments_fee(armor_order, amount)
    toadlane_fee_percentage = Fee.find_by(:module_name => "Armor Payments").value
    toadlane_fee = amount * toadlane_fee_percentage / 100

    seller_charged_fee = armor_fee + toadlane_fee

    # armor_order.amount is the order amount
    amount_after_fee_to_seller = armor_order.amount - seller_charged_fee

    armor_order.update_attributes({
      seller_charged_fee: seller_charged_fee,
      amount_after_fee_to_seller: amount_after_fee_to_seller
    })
  end

  def promise_order_process(product)
    if params["promise_order_id"].present? && params["inspection_date"].present? && params["inspection_date"]["inspection_date_id"].present?
      promise_order = PromiseOrder.find_by_id(params["promise_order_id"])
      promise_order.update_attributes({
        unit_price: product.unit_price,
        count: params[:count],
        amount: params[:total],
        rebate_price: params[:rebate],
        rebate_percent: params[:rebate_percent],
        fee: params[:fee] # this is fee amount for buyer
      })

      calculate_store_seller_fees(promise_order)

      selected_inspection_date = InspectionDate.find_by_id(params["inspection_date"]["inspection_date_id"])

      inspection_date = InspectionDate.new({
        promise_order_id: promise_order.id,
        approved: true,
        creator_type: selected_inspection_date.creator_type,
        date: selected_inspection_date.date
      })
      inspection_date.save(validate: false)

    elsif params["inspection_date"].present? && params["inspection_date"]["inspection_date_id"].present?
      # this is for selecting one inspection date from seller added dates
      promise_order = PromiseOrder.create({
        buyer_id: current_user.id,
        seller_id: product.user.id,
        product_id: product.id,
        unit_price: product.unit_price,
        count: params[:count],
        amount: params[:total],
        rebate_price: params[:rebate],
        rebate: params[:rebate_percent],
        fee: params[:fee], # this is fee amount for buyer

      })

      calculate_store_seller_fees(promise_order)

      selected_inspection_date = InspectionDate.find_by_id(params["inspection_date"]["inspection_date_id"])

      inspection_date = InspectionDate.new({
        promise_order_id: promise_order.id,
        approved: true,
        creator_type: selected_inspection_date.creator_type,
        date: selected_inspection_date.date
      })
      inspection_date.save(validate: false)

    elsif params["promise_order_id"].present?
      promise_order = PromiseOrder.find_by_id(params["promise_order_id"])
    elsif request.get? && session[:promise_order_id].present?
      promise_order = PromiseOrder.find_by_id(session[:promise_order_id])
    else
      promise_order = PromiseOrder.new
    end

    session[:promise_order_id] = promise_order.id

    promise_account = current_user.promise_account_exist? ? current_user.promise_account : PromiseAccount.new

    [promise_order, promise_account]
  end

  def calculate_store_seller_fees(promise_order)
    order_amount = promise_order.amount
    transaction_fee = Fee.find_by(:fee_type => "Transaction Fee").value.to_f
    fraud_protection_fee = Fee.find_by(:fee_type => "Fraud Protection").value.to_f
    end_user_support_fee = Fee.find_by(:fee_type => "End User Support").value.to_f

    transaction_fee_amount = order_amount * transaction_fee / 100
    fraud_protection_fee_amount = order_amount * fraud_protection_fee / 100
    end_user_support_fee_amount = order_amount * end_user_support_fee / 100

    seller_charged_fee = transaction_fee_amount + fraud_protection_fee_amount +
                        end_user_support_fee_amount

    amount_after_fee_to_seller = order_amount - seller_charged_fee

    promise_order.update_attributes({
      transaction_fee_amount: transaction_fee_amount,
      fraud_protection_fee_amount: fraud_protection_fee_amount,
      end_user_support_fee_amount: end_user_support_fee_amount,
      seller_charged_fee: seller_charged_fee,
      amount_after_fee_to_seller: amount_after_fee_to_seller
    })
  end
end
