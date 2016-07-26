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
    armor_order = ArmorOrder.find_by_id(params[:armor_order_id])

    product = Product.unexpired.find(params[:product_id])

    inspection_date = DateTime.new(
                                    params["armor_order"]["inspection_date(1i)"].to_i,
                                    params["armor_order"]["inspection_date(2i)"].to_i,
                                    params["armor_order"]["inspection_date(3i)"].to_i,
                                    params["armor_order"]["inspection_date(4i)"].to_i,
                                    params["armor_order"]["inspection_date(5i)"].to_i)

    if armor_order.update_attributes({buyer_id: current_user.id, seller_id: product.user.id, product_id: product.id, inspection_date: inspection_date})
      UserMailer.send_inspection_date_set_notification_to_seller(armor_order).deliver_now
      redirect_to product_path(product.id), :flash => { :notice => 'Your request to set inspectiond date has been informed to the seller.'}
    else
      redirect_to product_checkout_path(product_id: product.id, armor_order_id: armor_order.id), :flash => { :alert => armor_order.errors.full_messages.first}
    end
  end

  def update
    product = Product.unexpired.find(armor_order_params[:product_id])
    armor_order = ArmorOrder.find_by_id(params[:id])
    inspection_date_approved_by_seller = armor_order_params["inspection_date_approved_by_seller"] == "1" ? true : false

    if armor_order.inspection_date.nil?
      armor_order.update_attribute(:inspection_date, product.inspection_date)
    end

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
      inspection_date_approved_by_seller: inspection_date_approved_by_seller
    }

    if armor_order.update_attributes(additional_params)

      api_armor_order_params = {
        'seller_id'   => "#{product.user.armor_profile.armor_user_id}",
        'buyer_id'    => "#{current_user.armor_profile.armor_user_id}",
        'amount'      => armor_order_params["total"],
        'summary'     => product.name,
        'description' => product.description
      }
      armor_order.create_armor_api_order(current_user.armor_profile.armor_account_id, api_armor_order_params)

      seller_account_id = armor_order.seller_account_id

      armor_order.get_armor_payment_instruction_url(seller_account_id)

      # redirect_to dashboard_orders_path(armor_order, type: 'armor'), :flash => { :notice => 'Armor Order was successfully created.'}
      redirect_to product_checkout_path(product_id: product.id, armor_order_id: armor_order.id), :flash => { :notice => 'Armor Order was successfully created.'}
    else
      redirect_to :back, :flash => { :alert => armor_order.errors.messages}
    end
  rescue ArmorService::BadResponseError => e
    redirect_to dashboard_accounts_path, :flash => { :error => e.errors.values.flatten }
  end

  def destroy
    @armor_order.destroy
    respond_to do |format|
      format.html { redirect_to armor_orders_url }
      format.json { head :no_content }
    end
  end

  private
    def set_armor_order
      @armor_order = ArmorOrder.find(params[:id])
    end

    def armor_order_params
      params.require(:armor_order).permit!
      #(:seller_id, :buyer_id, :order_id, :account_id, :status, :amount, :summary, :description, :invoice_num, :purchase_order_num, :status_change, :uri)
    end
end
