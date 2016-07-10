class GreenOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def show
    @green_order = GreenOrder.find(params[:id])
  end

  def create
    unless green_params_valid?
      redirect_to product_path(green_order_params[:product_id]), alert: "Missing required fields for eCheck."
      return
    end
    response = GreenOrder.make_request(
      green_params,
      green_order_params[:seller_id],
      green_order_params[:product_id],
      green_order_params[:buyer_id],
      green_order_params[:total]
      )
    if response['Result'] == '0'
      gop = green_order_params
      gop[:check_number] = response['CheckNumber']
      gop[:check_id] = response['Check_ID']
      if gop[:address_id] == "-1"
        address = Address.new
        address.name = green_params["name"]
        address.line1 = green_params["address1"]
        address.line2 = green_params["address2"]
        address.zip = green_params["zip"]
        address.state = green_params["state"]
        address.city = green_params["city"]
        address.country = green_params["country"]
        address.user = current_user
        address.save
        gop[:address_id] = address.ids
      end
      @green_order = GreenOrder.new(gop)
      if @green_order.save
        @green_order.place_order

        UserMailer.sales_order_notification_to_seller(@green_order).deliver_now
        UserMailer.sales_order_notification_to_buyer(@green_order).deliver_now

        redirect_to dashboard_order_path(@green_order, :type => "green"), notice: "Your order was succesfully placed."
      else
        redirect_to product_checkout_path(green_order_params[:product_id], total: green_order_params[:total], count: green_order_params[:count], fee: green_order_params[:fee], shipping_cost: green_order_params[:shipping_cost], rebate: green_order_params[:rebate], rebate_percent: green_order_params[:rebate_percent]), alert: "#{@green_order.errors.full_messages.to_sentence}"
      end
    else
      redirect_to product_checkout_path(green_order_params[:product_id], total: green_order_params[:total], count: green_order_params[:count], fee: green_order_params[:fee], shipping_cost: green_order_params[:shipping_cost], rebate: green_order_params[:rebate], rebate_percent: green_order_params[:rebate_percent]), alert: "GreenByPhone Response: #{response['ResultDescription']}"
      return
    end
  end

  private
    def green_order_params
      params.require(:green_order).permit(:buyer_id, :seller_id, :product_id, :status, :unit_price, :count, :fee, :rebate, :rebate_percent, :total, :summary,
                                           :description, :shipping_address, :shipping_request, :shipping_details, :tracking_number, :deleted, :shipping_cost,
                                           :address_name, :address_city, :address_state, :address_country, :address_zip, :address_id, :shipping_estimate_id)
    end

    def green_params
      params.require(:green_order).permit(:name, :email_address, :phone, :address1, :address2, :city, :state, :zip, :country, :routing_number, :account_number)
    end

    def green_params_valid?
      ![green_params[:name], green_params[:email_address], green_params[:phone], green_params[:address1], green_params[:city], green_params[:state], green_params[:zip], green_params[:routing_number], green_params[:account_number]].any? {|p| p.blank?}
    end

end
