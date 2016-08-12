class GreenOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @green_order = GreenOrder.find(params[:id])
  end

  def create
    response = make_green_request
    if response['Result'] == '0'
      handle_successful_response(green_order_params, response)
    else
      render_on_failure(response)
    end
  end

  private

  def make_green_request
    amount = 0.00
    if green_order_params[:total].to_f > GreenOrder::MAX_AMOUNT
      amount = GreenOrder::MAX_AMOUNT
    else
      amount = green_order_params[:total]
    end
    GreenOrder.make_request(
      green_params,
      green_order_params[:seller_id],
      green_order_params[:product_id],
      green_order_params[:buyer_id],
      amount
    )
  end

  def green_order_params
    @green_order_params ||= params.require(:green_order).permit(
      :id,
      :name,
      :email_address,
      :phone,
      :address1,
      :address2,
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
      :shipping_estimate_id,
      :routing_number,
      :account_number
    )
  end

  def green_params
    params.require(:green_order).permit(
      :id,
      :name,
      :email_address,
      :phone,
      :address1,
      :address2,
      :address_city,
      :address_state,
      :address_zip,
      :address_country,
      :routing_number,
      :account_number
    )
  end

  def address_params
    {
      name: green_params['name'],
      line1: green_params['address1'],
      line2: green_params['address2'],
      zip: green_params['address_zip'],
      state: green_params['address_state'],
      city: green_params['address_city'],
      country: green_params['address_country']
    }
  end

  def prepare_rendering_data
    @product = Product.find(green_order_params[:product_id])
    @data = {
      total: green_order_params[:total],
      quantity: green_order_params[:count],
      fee_amount: green_order_params[:fee],
      shipping_cost: green_order_params[:shipping_cost],
      rebate: green_order_params[:rebate],
      rebate_percent: green_order_params[:rebate_percent],
      available_product: @product.remaining_amount
    }
    @fee = Fee.find_by(:module_name => 'Stripe').value
    @stripe_order = StripeOrder.new
    @amg_order = AmgOrder.new
    @green_order = GreenOrder.new(green_order_params)
  end

  def render_on_failure(response)
    prepare_rendering_data
    flash[:alert] = "#{response['ResultDescription']}"
    render 'products/checkout'
  end

  def create_address(green_order_params)
    if green_order_params[:address_id] == '-1'
      address = Address.new(address_params)
      address.user = current_user
      address.save
      green_order_params[:address_id] = address.id
    end
  end

  def send_after_order_emails(green_order)
    UserMailer.sales_order_notification_to_seller(green_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(green_order).deliver_later
  end

  def update_green_order_params(green_order_params, response)
    green_order_params[:check_number] = response['CheckNumber']
    green_order_params[:check_id] = response['Check_ID']
  end

  def handle_successful_response(green_order_params, response)
    update_green_order_params(green_order_params, response)
    create_address(green_order_params)
    @green_order = GreenOrder.new(green_order_params)
    if @green_order.save
      @green_order.process_checks_breakdown if (@green_order.total > GreenOrder::MAX_AMOUNT)
      @green_order.place_order
      send_after_order_emails(@green_order)
      redirect_to dashboard_order_path(
        @green_order,
        type: 'green'
      ), notice: 'Your order was successfully placed.'
    end
  end
end
