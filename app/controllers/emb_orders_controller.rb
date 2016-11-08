class EmbOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @emb_order = EmbOrder.find(params[:id])
  end

  def create
    if emb_order_params[:total].to_f > 750
      response = {
        "response" => "3",
        "responsetext" => "The amount can't exceed $750",
        "authcode" => "",
        "transactionid" => "",
        "avsresponse" => "",
        "cvvresponse" => "",
        "orderid" => "",
        "type" => "sale",
        "response_code" => ""
      }
      render_on_failure(response)
    else
      response = make_emb_request
      if response['response'] == '1'
        handle_successful_response(emb_order_params, response)
      else
        render_on_failure(response)
      end
    end
  end

  private

  def make_emb_request
    emb_params_including_billing = emb_params
    emb_params_including_billing.merge!(params.slice('billing-cc-number', 'billing-cc-exp', 'billing-cvv'))
    EmbOrder.make_request(
      emb_params_including_billing,
      emb_order_params[:seller_id],
      emb_order_params[:product_id],
      emb_order_params[:buyer_id],
      emb_order_params[:total]
    )
  end

  def emb_order_params
    @emb_order_params ||= params.require(:emb_order).permit(
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

  def emb_params
    params.require(:emb_order).permit(
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
      name: emb_params['name'],
      line1: emb_params['address1'],
      zip: emb_params['address_zip'],
      state: emb_params['address_state'],
      city: emb_params['address_city'],
      country: emb_params['address_country']
    }
  end

  def prepare_rendering_data
    @product = Product.find(emb_order_params[:product_id])
    @data = {
      total: emb_order_params[:total],
      quantity: emb_order_params[:count],
      fee_amount: emb_order_params[:fee],
      shipping_cost: emb_order_params[:shipping_cost],
      rebate: emb_order_params[:rebate],
      rebate_percent: emb_order_params[:rebate_percent],
      available_product: @product.remaining_amount
    }
    @fee = Fee.find_by(:module_name => 'Stripe').value
    @stripe_order = StripeOrder.new
    @green_order = GreenOrder.new
    @amg_order = AmgOrder.new
    @emb_order = EmbOrder.new(emb_order_params)
  end

  def render_on_failure(response)
    prepare_rendering_data
    flash[:alert] = "#{response['responsetext']}"
    render 'products/checkout'
  end

  def create_address(emb_order_params)
    if emb_order_params[:address_id] == '-1'
      address = Address.new(address_params)
      address.user = current_user
      address.save
      emb_order_params[:address_id] = address.id
    end
  end

  def send_after_order_emails(emb_order)
    UserMailer.sales_order_notification_to_seller(emb_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(emb_order).deliver_later
    NotificationCreator.new(emb_order).after_order_created
  end

  def update_emb_order_params(emb_order_params, response)
    emb_order_params[:transaction_id] = response['transactionid']
    emb_order_params[:authorization_code] = response['authcode']
  end

  def handle_successful_response(emb_order_params, response)
    update_emb_order_params(emb_order_params, response)
    create_address(emb_order_params)
    @emb_order = EmbOrder.new(emb_order_params)
    if @emb_order.save
      @emb_order.place_order
      send_after_order_emails(@emb_order)
      redirect_to dashboard_order_path(
        @emb_order,
        type: 'emb'
      ), notice: 'Your order was successfully placed.'
    else
      prepare_rendering_data
      flash[:alert] = "#{@emb_order.errors.full_messages.to_sentence}"
      render 'products/checkout'
    end
  end
end
