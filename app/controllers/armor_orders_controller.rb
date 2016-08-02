class ArmorOrdersController < ApplicationController
  before_action :check_if_user_active
  before_action :set_armor_order, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def index
    @armor_orders = ArmorOrder.all
  end

  def show
  end

  def new
    @armor_order = ArmorOrder.new
  end

  def edit
  end

  def create

  end

  def set_inspection_date
    product = Product.unexpired.find(params[:product_id])

    inspection_date = DateTime.new(
                                    params["armor_order"]["inspection_date_by_buyer(1i)"].to_i,
                                    params["armor_order"]["inspection_date_by_buyer(2i)"].to_i,
                                    params["armor_order"]["inspection_date_by_buyer(3i)"].to_i,
                                    params["armor_order"]["inspection_date_by_buyer(4i)"].to_i,
                                    params["armor_order"]["inspection_date_by_buyer(5i)"].to_i
                                  )

    armor_order = ArmorOrder.create

    additional_params = {

      status_change: DateTime.now,
      product_id: product.id,
      buyer_id: current_user.id,
      seller_id: product.user.id,
      summary: product.name,
      description: product.description,
      amount: armor_order_params["total"],
      unit_price: armor_order_params["unit_price"],
      count: armor_order_params["count"],
      fee: armor_order_params["fee"],
      rebate: armor_order_params["rebate"],
      rebate_price: armor_order_params["rebate_price"],
      shipping_cost: armor_order_params["shipping_cost"],
    }

    armor_order.update_attributes(additional_params)

    if product.user == current_user
      set_inspection_date_notify_buyer(armor_order, inspection_date, product)
    else
      set_inspection_date_notify_seller(armor_order, inspection_date, product)
    end
  end

  def confirm_inspection_date_by_seller
    armor_order = ArmorOrder.find_by_id(params[:armor_order_id])

    product = Product.unexpired.find(params[:product_id])

    if armor_order.update_attributes({inspection_date_by_seller: armor_order.inspection_date_by_buyer, inspection_date_approved_by_seller: true})
      UserMailer.send_inspection_date_confirm_notification_to_buyer(armor_order).deliver_now
      redirect_to product_path(id: product.id), :flash => { :notice => "Inspection date has been set to #{armor_order.inspection_date_by_seller} and has been informed to buyer."}
    else
      redirect_to product_path(id: product.id)
    end
  end

  def update
    armor_order = ArmorOrder.find_by_id(params[:id])
    product = armor_order.product
    inspection_date_approved_by_seller = armor_order_params["inspection_date_approved_by_seller"] == "1" ? true : false

    additional_params = {
      inspection_date_approved_by_seller: inspection_date_approved_by_seller,
      inspection_date_approved_by_buyer: true
    }

    if armor_order.update_attributes(additional_params)

      api_armor_order_params = {
        'seller_id'   => "#{product.user.armor_profile.armor_user_id}",
        'buyer_id'    => "#{current_user.armor_profile.armor_user_id}",
        'amount'      => armor_order.amount,
        'summary'     => product.name,
        'description' => product.description,
        'inspection' => true,
        'goodsmilestones'=>
          [
            {
              'name': 'Order created',
              'amount': 0,
              'escrow': 0
            },
            {
              'name': 'Goods inspected',
              'amount': 0,
              'escrow': 0
            },
            {
              'name': 'Goods shipped',
              'amount': 0,
              'escrow': 0
            },
            {
              'name': 'Order released',
              'amount': armor_order.amount,
              'escrow': armor_order.amount
            }
          ]
        }

      armor_order.create_armor_api_order(api_armor_order_params)

      armor_order.get_armor_payment_instruction_url

      # redirect_to dashboard_orders_path(armor_order, type: 'armor'), :flash => { :notice => 'Armor Order was successfully created.'}
      redirect_to product_checkout_path(product_id: product.id, armor_order_id: armor_order.id), :flash => { :notice => 'Armor Order was successfully created.'}
    else
      redirect_to product_checkout_path(product_id: product.id, armor_order_id: armor_order.id), :flash => { :alert => armor_order.errors.messages}
    end
  rescue ArmorService::BadResponseError => e
    redirect_to product_checkout_path(product_id: product.id, armor_order_id: armor_order.id), :flash => { :error => e.errors.values.flatten }
  end

  def destroy
    @armor_order.destroy
    respond_to do |format|
      format.html { redirect_to armor_orders_url }
      format.json { head :no_content }
    end
  end

  def complete_inspection
    armor_order = ArmorOrder.find_by_id(params["armor_order_id"])
    client = ArmorService.new
    action_data = {
                    "action" => "completeinspection",
                    "confirm" => true }

    response = client.orders(armor_order.seller_account_id).update(armor_order.order_id, action_data)
    armor_order.update_attribute(:inspection_complete, true)

    # shipping details
    account_id = armor_order.seller.armor_profile.armor_account_id
    order_id = armor_order.order_id
    action_data = {
                      "user_id" => armor_order.seller.armor_profile.armor_user_id,
                      "carrier_id" => 8,
                      "tracking_id" => "z1234567890",
                      "description" => "Shipped via UPS ground in a protective box." }
    result = client.orders(account_id).shipments(order_id).create(action_data)

    # release fund by buyer
    seller_account_id = armor_order.seller_account_id
    order_response = client.orders(seller_account_id).get(armor_order.order_id)

    order_uri = order_response.data[:body]["uri"]

    buyer_account_id = armor_order.buyer.armor_profile.armor_account_id
    buyer_user_id = armor_order.buyer.armor_profile.armor_user_id

    auth_data = {
                  'uri' => order_uri,
                  'action' => 'release' }

    result = client.users(buyer_account_id).authentications(buyer_user_id).create(auth_data)
    armor_order.update_attribute(:payment_release_url, result.data[:body]["url"])

    redirect_to products_under_inspection_dashboard_products_path(payment_release_url: armor_order.payment_release_url, type: 'complete'), :flash => { :notice => "Completed inspection and released fund" }
  rescue ArmorService::BadResponseError => e
    redirect_to products_under_inspection_dashboard_products_path(type: 'incomplete'), :flash => { :error => e.errors.values.flatten }
  end

  private
    def set_armor_order
      @armor_order = ArmorOrder.find(params[:id])
    end

    def armor_order_params
      params.require(:armor_order).permit!
      #(:seller_id, :buyer_id, :order_id, :account_id, :status, :amount, :summary, :description, :invoice_num, :purchase_order_num, :status_change, :uri)
    end

    def set_inspection_date_notify_buyer(armor_order, inspection_date, product)
      if armor_order.update_attributes({inspection_date_by_seller: inspection_date , inspection_date_approved_by_seller: true})
        UserMailer.send_inspection_date_set_notification_to_buyer(armor_order).deliver_now
        redirect_to product_path(id: product.id), :flash => { :notice => 'New inspection date has been set and has been notified to buyer.'}
      else
        redirect_to product_path(id: product.id), :flash => { :alert => armor_order.errors.full_messages.first}
      end
    end

    def set_inspection_date_notify_seller(armor_order, inspection_date, product)
      if armor_order.update_attributes({buyer_id: current_user.id, seller_id: product.user.id, product_id: product.id, inspection_date_by_buyer: inspection_date})
        UserMailer.send_inspection_date_set_notification_to_seller(armor_order).deliver_now
        redirect_to product_checkout_path(product_id: armor_order.product.id, armor_order_id: armor_order.id), :flash => { :notice => 'Your request to set inspectiond date has been informed to the seller.'}
      else
        redirect_to product_checkout_path(product_id: armor_order.product.id, armor_order_id: armor_order.id), :flash => { :alert => armor_order.errors.full_messages.first}
      end
    end
end
