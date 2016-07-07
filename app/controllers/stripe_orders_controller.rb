class StripeOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @stripe_order = StripeOrder.find(params[:id])
  end

  def create
    if stripe_order_params[:address_id] == "-1"
      address = Address.new
      address.name = stripe_params["stripeShippingName"]
      address.line1 = stripe_params["stripeShippingAddressLine1"]
      address.line2 = stripe_params["stripeShippingAddressLine2"]
      address.zip = stripe_params["stripeShippingAddressZip"]
      address.state = stripe_params["stripeShippingAddressState"]
      address.city = stripe_params["stripeShippingAddressCity"]
      address.country = stripe_params["stripeShippingAddressCountry"]
      address.user = current_user
      address.save
      stripe_order_params[:address_id] = address.id
    end

    @stripe_order = StripeOrder.new(stripe_order_params)
    @stripe_order.address = address
    if @stripe_order.save
      @stripe_order.start_stripe_order(stripe_params["stripeToken"])

      @stripe_order.calculate_shipping()

      @stripe_order.process_payment()

      UserMailer.sales_order_notification_to_seller(@stripe_order).deliver_now
      UserMailer.sales_order_notification_to_buyer(@stripe_order).deliver_now
      redirect_to dashboard_order_path(@stripe_order, :type => "stripe"), notice: "Your order was succesfully placed."
    else
      redirect_to :back, alert: "#{@stripe_order.errors.full_messages.to_sentence}"
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

    def green_params
      params.require(:green_order).permit(:name, :email_address, :phone, :address1, :address2, :city, :state, :zip, :country, :routing_number, :account_number)
    end

    def green_params_valid?
      ![green_params[:name], green_params[:email_address], green_params[:phone], green_params[:address1], green_params[:city], green_params[:state], green_params[:zip], green_params[:routing_number], green_params[:account_number]].any? {|p| p.blank?}
    end

    def green_order_params
      stripe_order_params.except(:id, :stripe_charge_id)
    end

end
