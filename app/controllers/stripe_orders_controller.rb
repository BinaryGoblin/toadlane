class StripeOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @stripe_order = StripeOrder.find(params[:id])
  end
<<<<<<< HEAD
=======
#<<<<<<< HEAD
  
#=======
 
#>>>>>>> 995900920cfc1a063731bf907bfd97d5dc5fbce8
>>>>>>> 3dbc7d5187d2fb18f52f8c7b3a0d9095d8fff271


  def create
    if stripe_order_params[:address_id] == "-1"
      @address = Address.new
      @address.name = stripe_params["stripeShippingName"]
      @address.line1 = stripe_params["stripeShippingAddressLine1"]
      @address.line2 = stripe_params["stripeShippingAddressLine2"]
      @address.zip = stripe_params["stripeShippingAddressZip"]
      @address.state = stripe_params["stripeShippingAddressState"]
      @address.city = stripe_params["stripeShippingAddressCity"]
      @address.country = stripe_params["stripeShippingAddressCountry"]
      @address.user = current_user
      @address.save(validate: false)
    else
      @address = Address.find stripe_order_params[:address_id]
    end

    @stripe_order = StripeOrder.new(stripe_order_params)
    @stripe_order.address_id = @address.id

    if @stripe_order.save(validate: false)
      @stripe_order.start_stripe_order(stripe_params["stripeToken"])

      @stripe_order.calculate_shipping()

      @stripe_order.process_payment()

      Services::ActivityTracker.track(current_user, @stripe_order)

      UserMailer.sales_order_notification_to_seller(@stripe_order).deliver_later
      UserMailer.sales_order_notification_to_buyer(@stripe_order).deliver_later
      NotificationCreator.new(@stripe_order).after_order_created
      redirect_to dashboard_order_path(@stripe_order, :type => "stripe"), notice: "Your order was successfully placed."
    else
      redirect_to product_checkout_path(stripe_order_params[:product_id], total: stripe_order_params[:total], count: stripe_order_params[:count], fee: stripe_order_params[:fee], shipping_cost: stripe_order_params[:shipping_cost], rebate: stripe_order_params[:rebate], rebate_percent: stripe_order_params[:rebate_percent]), alert: "#{@stripe_order.errors.full_messages.to_sentence}"
    end
  end

  private
  def stripe_order_params
    params.require(:stripe_order).permit(:id, :buyer_id, :seller_id, :product_id, :stripe_charge_id, :status, :unit_price, :count, :fee, :rebate, :total, :summary,
      :description, :shipping_address, :shipping_request, :shipping_details, :tracking_number, :deleted, :shipping_cost,
    :address_name, :address_city, :address_state, :address_country, :address_zip, :address_id, :shipping_estimate_id)
  end

  def stripe_params
    params.permit(:stripeToken, :stripeEmail, :stripeShippingName, :stripeShippingAddressLine1, :stripeShippingAddressLine2,
    :stripeShippingAddressZip, :stripeShippingAddressState, :stripeShippingAddressCity, :stripeShippingAddressCountry)
  end
end
