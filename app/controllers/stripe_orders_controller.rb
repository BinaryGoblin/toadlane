class StripeOrdersController < ApplicationController
  def show
    @stripe_order = StripeOrder.find(params[:id])
  end
 
  def create
    @stripe_order = StripeOrder.new(stripe_order_params)
    @stripe_order.save
    @stripe_order.start_stripe_order(stripe_params["stripeToken"])
    redirect_to @stripe_order, notice: "Your order was succesfully placed."
  end
  
  def purchase
    @stripe_order = StripeOrder.new
    @stripe_order.update_attributes(stripe_order_params)
    @stripe_order.buyer = current_user
    @stripe_order.seller = @stripe_order.product.user
    @stripe_order.process_payment(stripe_params["stripeToken"])
    @stripe_order.address_name = stripe_params["stripeShippingName"]
    if stripe_params["stripeShippingAddressLine2"].nil?
      @stripe_order.shipping_address = stripe_params["stripeShippingAddressLine1"]
    else
      @stripe_order.shipping_address = (stripe_params["stripeShippingAddressLine1"] + ", " + stripe_params["stripeShippingAddressLine2"])
    end
    @stripe_order.address_zip = stripe_params["stripeShippingAddressZip"]
    @stripe_order.address_state = stripe_params["stripeShippingAddressState"]
    @stripe_order.address_city = stripe_params["stripeShippingAddressCity"]
    @stripe_order.address_country = stripe_params["stripeShippingAddressCountry"]
    @stripe_order.save
    redirect_to @stripe_order, notice: "Order was successfully placed."
  end
  
  private
    def stripe_order_params
      params.require(:stripe_order).permit(:id, :buyer_id, :seller_id, :product_id, :stripe_charge_id, :status, :unit_price, :count, :fee, :rebate, :total, :summary,
                                           :description, :shipping_address, :shipping_request, :shipping_details, :tracking_number, :deleted, :shipping_cost,
                                           :address_name, :address_city, :address_state, :address_country, :address_zip)
    end
    
    def stripe_params
      params.permit(:stripeToken, :stripeEmail, :stripeShippingName, :stripeShippingAddressLine1, :stripeShippingAddressLine2,
                    :stripeShippingAddressZip, :stripeShippingAddressState, :stripeShippingAddressCity, :stripeShippingAddressCountry)
    end
end