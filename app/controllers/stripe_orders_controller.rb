class StripeOrdersController < ApplicationController
  def show
    @stripe_order = StripeOrder.find(params[:id])
  end
 
  def create
    @stripe_order = StripeOrder.new(stripe_order_params)
    @stripe_order.save
    @stripe_order.start_stripe_order(stripe_params["stripeToken"])
    
    if params[ :address_id ] = -1
      address = Address.new
      address.name = stripe_params["stripeShippingName"]
      address.line1 = stripe_params["stripeShippingAddressLine1"]
      address.line2 = stripe_params["stripeShippingAddressLine2"]
      address.zip = stripe_params["stripeShippingAddressZip"]
      address.state = stripe_params["stripeShippingAddressState"]
      address.city = stripe_params["stripeShippingAddressCity"]
      address.country = stripe_params["stripeShippingAddressCountry"]
      address.user = @stripe_order.buyer
      
      @stripe_order.address = address
    end
      
    @stripe_order.process_payment()
    redirect_to dashboard_order_path(@stripe_order, :type => "stripe"), notice: "Your order was succesfully placed."
  end
  
  private
    def stripe_order_params
      params.require(:stripe_order).permit(:id, :buyer_id, :seller_id, :product_id, :stripe_charge_id, :status, :unit_price, :count, :fee, :rebate, :total, :summary,
                                           :description, :shipping_address, :shipping_request, :shipping_details, :tracking_number, :deleted, :shipping_cost,
                                           :address_name, :address_city, :address_state, :address_country, :address_zip, :shipping_estimate_attributes => [ :id, 
                                           :cost, :description, :product_id, :_destroy ], :address_attributes => [ :id, :line1, :line2, :city, :state, :country, :zip ])
    end
    
    def stripe_params
      params.permit(:stripeToken, :stripeEmail, :stripeShippingName, :stripeShippingAddressLine1, :stripeShippingAddressLine2,
                    :stripeShippingAddressZip, :stripeShippingAddressState, :stripeShippingAddressCity, :stripeShippingAddressCountry)
    end
end