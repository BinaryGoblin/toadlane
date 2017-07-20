class ProductsController < ApplicationController

  # impressionist is for allowing view count and ease of it
  # impressionist :actions=>[:show], :unique => [:user_id]
  layout 'user_dashboard'

  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def index
    @i_buy_and_sell = current_user.i_buy_and_sell_present? ? 'true' : 'false'

    @most_viewed_products = Product.most_viewed_products.sample(7)
    @newest_products = Product.newest_products.first(7)
    @folders = Folder.importing_completed
    @latest_activities = current_user.latest_activities

    AddViewedTasksJob.perform_later(current_user, @latest_activities.to_a) if @latest_activities.present?
  end

  def show
    # if current_user.present? && !current_user.profile_complete?
    #   redirect_to dashboard_profile_path, :flash => { :error => "You must complete your profile before you can view product details." }
    #   return
    # end
    set_product

    set_nil_fly_buy_order_id_session

    impressionist(@product)

    @stripe_order = StripeOrder.new
    if @product.default_payment_flybuy?
      @fee = Fee.find_by(:module_name => "Fly & Buy").value
    elsif @product.default_payment_same_day?
      @fee = Fee.find_by(:module_name => "Same day").value
    else
      @fee = Fee.find_by(:module_name => "Stripe").value
    end
    commontator_thread_show(@product)
    # impressionist(@product)
    @related_products = Product.unexpired.where(main_category: @product.main_category).where.not(id: @product.id)

    if params[:fly_buy_order_id].present?
      @fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    else
      @fly_buy_order = FlyBuyOrder.new
    end
  end

  def products
    @products = Product.unexpired.for_sell.order_by_modified_date.paginate(page: params[:page], per_page: params[:count])
  end

  def deals
    # TODO
  end

  def for_sale
    unexpired_products = Product.unexpired.where(status_characteristic: 'sell').order('id DESC')
    @products = unexpired_products.select { |p| p.if_fly_buy_check_valid_inspection_date }.paginate(page: params[:page], per_page: params[:count])
    render 'products/products'
  end

  def requested
    # TODO Disabling this during Stripe integration by calling for 'buy' instead of 'sell'
    unexpired_products = Product.unexpired.where(status_characteristic: 'buy').order('id DESC')
    @products = unexpired_products.select { |p| p.if_fly_buy_check_valid_inspection_date }.paginate(page: params[:page], per_page: params[:count])
    render 'products/products'
  end

  # TODO Refactor 10018
  def checkout
    @product = Product.find(params[:product_id])

    return redirect_to product_path(@product, error: :no_company_info) unless current_user.company.present?
    return redirect_to product_path(@product, error: :profile_not_completed) unless current_user.profile_complete?
    return redirect_to product_path(@product, error: :no_fly_buy_profile) unless current_user.fly_buy_profile_account_added?
    return redirect_to product_path(@product, error: :minimum_order_quantity) if params[:count].to_i < @product.minimum_order_quantity
    return redirect_to product_path(@product, error: :unverified_by_admin) if current_user.fly_buy_profile_account_added? && current_user.fly_buy_unverified_by_admin == true


    sum_unit_price = (@product.unit_price * params[:count].to_f)

    if @product.default_payment_flybuy?
      fee = Fee.find_by(module_name: 'Fly & Buy').value
      without_reduction_fees = sum_unit_price * fee.to_f / 100
      reduction_in_fees = without_reduction_fees * 75 / 100
      fees = without_reduction_fees - reduction_in_fees
      fly_buy_fee = over_million_dollars?(sum_unit_price) ? Fee::FLY_BUY[:over_million] : Fee::FLY_BUY[:under_million]
      fly_buy_fees = sum_unit_price * fly_buy_fee / 100
      number_of_items_to_inspect = inspected_items_count(params[:percentage_of_items_to_inspect].to_i, params[:count].to_i)
      inspection_service_fee = number_of_items_to_inspect * Product::INSPECTION_SERVICE_PRICE
    elsif @product.default_payment_same_day?
      fee = Fee.find_by(module_name: 'Same day').value
      fees = sum_unit_price * fee.to_f / 100
      fly_buy_fees = nil
    else
      fee = Fee.find_by(module_name: 'Stripe').value
      fees = sum_unit_price * fee.to_f / 100
      fly_buy_fees = nil
    end

    total = sum_unit_price + fees + fly_buy_fees.to_f + params[:shipping_cost].to_f - params[:rebate].to_f + inspection_service_fee.to_f

    options = {
      quantity: params[:count],
      fee: fee,
      fee_amount: fees,
      shipping_cost: params[:shipping_cost],
      rebate: params[:rebate],
      rebate_percent: params[:rebate_percent],
      available_product: @product.remaining_amount,
      fly_buy_fee: fly_buy_fees,
      total: total,
      percentage_of_inspection_service: params[:percentage_of_items_to_inspect],
      inspection_service_cost: inspection_service_fee.to_f,
      inspection_service_comment: params[:inspection_service_note]
    }

    @data = options

    options.merge!({
      unit_price: @product.unit_price,
      fly_buy_order_id: params[:fly_buy_order_id],
      inspection_date_id: (params[:inspection_date][:inspection_date_id] rescue nil)
    })

    @fly_buy_order, @fly_buy_profile = fly_buy_order_process(@product, options)

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

  def fly_buy_order_process(product, options={})
    if options[:fly_buy_order_id].present? && options[:inspection_date_id].present?
      fly_buy_order = FlyBuyOrder.find_by_id(options[:fly_buy_order_id])
      fly_buy_order.update_attributes({
        unit_price: options[:unit_price],
        count: options[:quantity],
        total: options[:total],
        rebate_price: options[:rebate],
        rebate: options[:rebate_percent],
        fee: options[:fee_amount],
        fly_buy_fee: options[:fly_buy_fee],
        percentage_of_inspection_service: options[:percentage_of_inspection_service],
        inspection_service_cost: options[:inspection_service_cost],
        inspection_service_comment: options[:inspection_service_comment]
      })

      selected_inspection_date = InspectionDate.find_by_id(options[:inspection_date_id])
      save_inspection_date(selected_inspection_date, fly_buy_order)
    elsif options[:inspection_date_id].present? || @product.default_payment_same_day?
      fly_buy_order = FlyBuyOrder.find_by_id(session[:fly_buy_order_id]) if session[:fly_buy_order_id].present?
      order_type = @product.default_payment_same_day? ? 'same_day' : 'fly_buy'
      attrs = {
        unit_price: options[:unit_price],
        count: options[:quantity],
        total: options[:total],
        rebate_price: options[:rebate],
        rebate: options[:rebate_percent],
        fee: options[:fee_amount],
        percentage_of_inspection_service: options[:percentage_of_inspection_service],
        inspection_service_cost: options[:inspection_service_cost],
        inspection_service_comment: options[:inspection_service_comment],
        fly_buy_fee: options[:fly_buy_fee],
        order_type: order_type
      }

      if fly_buy_order.present?
        fly_buy_order.update_attributes(attrs)
      else
        attrs.merge!(buyer_id: current_user.id, seller_id: product.user.id, product_id: product.id)

        fly_buy_order = FlyBuyOrder.create(attrs)
      end

      unless @product.default_payment_same_day?
        selected_inspection_date = InspectionDate.find_by_id(options[:inspection_date_id])
        save_inspection_date(selected_inspection_date, fly_buy_order)
      end
    elsif request.get? && session[:fly_buy_order_id].present?
      fly_buy_order = FlyBuyOrder.find_by_id(session[:fly_buy_order_id])
    elsif options[:fly_buy_order_id].present?
      fly_buy_order = FlyBuyOrder.find_by_id(options[:fly_buy_order_id])
    else
      fly_buy_order = FlyBuyOrder.new
    end

    session[:fly_buy_order_id] = fly_buy_order.id

    fly_buy_profile = current_user.fly_buy_profile_account_added? ? current_user.fly_buy_profile : FlyBuyProfile.new

    if product.group.present?
      fly_buy_order.update_attributes(group_seller_id: product.group.id, group_seller: true)
      fly_buy_order.reload
    end

    fly_buy_order.create_additional_seller_fee_transactions

    [fly_buy_order, fly_buy_profile]
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

  def save_inspection_date(selected_inspection_date, fly_buy_order)
    if selected_inspection_date.fly_buy_order_id == fly_buy_order.id
      selected_inspection_date.update_attributes({
        approved: true,
        creator_type: selected_inspection_date.creator_type,
        date: selected_inspection_date.date
      })
    else
      inspection_date = InspectionDate.new({
        fly_buy_order_id: fly_buy_order.id,
        approved: true,
        creator_type: selected_inspection_date.creator_type,
        date: selected_inspection_date.date
      })
      inspection_date.save(validate: false)
    end
  end

  def over_million_dollars?(amount)
    amount > 1000000
  end

  def set_nil_fly_buy_order_id_session
    session[:fly_buy_order_id] = nil
  end
end
