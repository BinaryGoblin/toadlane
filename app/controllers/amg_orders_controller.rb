class AmgOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @amg_order = AmgOrder.find(params[:id])
  end

  def create
    response = make_amg_request
    if response['response'] == '1'
      handle_successful_response(amg_order_params, response)
    else
      render_on_failure(response)
    end
  end

  private

  def make_amg_request
    amg_params_including_billing = amg_params
    amg_params_including_billing.merge!(params.slice('billing-cc-number', 'billing-cc-exp', 'billing-cvv'))
    AmgOrder.make_request(
      amg_params_including_billing,
      amg_order_params[:seller_id],
      amg_order_params[:product_id],
      amg_order_params[:buyer_id],
      amg_order_params[:total]
    )
  end

  def amg_order_params
    @amg_order_params ||= params.require(:amg_order).permit(
      :id,
      :first_name,
      :last_name,
      :address1,
      :buyer_id,
      :seller_id,
      :product_id,
      :status,
      :unit_price,
      :count,
      :fee,
      :rebate,
      :rebate_percent,
      :total,
      :summary,
      :description,
      :shipping_address,
      :shipping_request,
      :shipping_details,
      :tracking_number,
      :deleted,
      :shipping_cost,
      :address_name,
      :address_city,
      :address_state,
      :address_country,
      :address_zip,
      :address_id,
      :shipping_estimate_id
    )
  end

  def amg_params
    params.require(:amg_order).permit(
      :id,
      :first_name,
      :last_name,
      :address1,
      :address_city,
      :address_state,
      :address_zip,
      :address_country
    )
  end

  def address_params
    {
      name: amg_params['name'],
      line1: amg_params['address1'],
      zip: amg_params['address_zip'],
      state: amg_params['address_state'],
      city: amg_params['address_city'],
      country: amg_params['address_country']
    }
  end

  def prepare_rendering_data
    @product = Product.find(amg_order_params[:product_id])
    @data = {
      total: amg_order_params[:total],
      quantity: amg_order_params[:count],
      fee_amount: amg_order_params[:fee],
      shipping_cost: amg_order_params[:shipping_cost],
      rebate: amg_order_params[:rebate],
      rebate_percent: amg_order_params[:rebate_percent],
      available_product: @product.remaining_amount
    }
    @fee = Fee.find_by(:module_name => 'Stripe').value
    @stripe_order = StripeOrder.new
    @green_order = GreenOrder.new
    @amg_order = AmgOrder.new(amg_order_params)
  end

  def render_on_failure(response)
    prepare_rendering_data
    flash[:alert] = "#{response['responsetext']}"
    render 'products/checkout'
  end

  def create_address(amg_order_params)
    if amg_order_params[:address_id] == '-1'
      address = Address.new(address_params)
      address.user = current_user
      address.save
      amg_order_params[:address_id] = address.id
    end
  end

  def send_after_order_emails(amg_order)
    UserMailer.sales_order_notification_to_seller(amg_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(amg_order).deliver_later
  end

  def update_amg_order_params(amg_order_params, response)
    amg_order_params[:transaction_id] = response['transactionid']
    amg_order_params[:authorization_code] = response['authcode']
  end

  def handle_successful_response(amg_order_params, response)
    update_amg_order_params(amg_order_params, response)
    create_address(amg_order_params)
    @amg_order = AmgOrder.new(amg_order_params)
    if @amg_order.save
      @amg_order.place_order
      send_after_order_emails(@amg_order)
      redirect_to dashboard_order_path(
        @amg_order,
        type: 'amg'
      ), notice: 'Your order was successfully placed.'
    else
      prepare_rendering_data
      flash[:alert] = "#{@amg_order.errors.full_messages.to_sentence}"
      render 'products/checkout'
    end
  end
end
