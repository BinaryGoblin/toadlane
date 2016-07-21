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
    product = Product.unexpired.find(armor_order_params[:product_id])
    
    additional_params = {
      buyer_id: current_user.id,
      seller_id: product.user.id,
      product_id: product.id,
      status_change: DateTime.now,
      summary: product.name,
      description: product.description,
      amount: armor_order_params["total"],
      unit_price: armor_order_params["unit_price"],
      count: armor_order_params["count"],
      fee: armor_order_params["fee"],
      rebate: armor_order_params["rebate"],
      rebate_price: armor_order_params["rebate_price"],
      shipping_cost: armor_order_params["shipping_cost"]
    }
    @armor_order = ArmorOrder.new(additional_params)
    if @armor_order.save

      api_armor_order_params = {
        'seller_id'   => "#{product.user.armor_profile.armor_user_id}",
        'buyer_id'    => "#{current_user.armor_profile.armor_user_id}",
        'amount'      => armor_order_params["total"],
        'summary'     => product.name,
        'description' => product.description
      }
      @armor_order.create_armor_api_order(current_user.armor_profile.armor_account_id, api_armor_order_params)

      redirect_to dashboard_orders_path, :flash => { :notice => 'Armor Order was successfully created.'}
    else
      redirect_to :back, :flash => { :alert => @armor_order.errors.messages}
    end
    # product = Product.unexpired.find(armor_order_params[:product_id])
    #
    # if product.status_characteristic == 'sell'
    #   additional_params = {
    #     buyer_id: current_user.id,
    #     seller_id: product.user.id,
    #     product_id: product.id,
    #     status_change: DateTime.now,
    #     account_id: current_user.armor_account_id
    #   }
    # else
    #   additional_params = {
    #     buyer_id: product.user.id,
    #     seller_id: current_user.id,
    #     product_id: product.id,
    #     status_change: DateTime.now,
    #     account_id: current_user.armor_account_id
    #   }
    # end
    #
    # @armor_order = ArmorOrder.new(armor_order_params.merge(additional_params))
    #
    # respond_to do |format|
    #   if @armor_order.save
    #
    #     api_armor_order_params = {
    #       'seller_id'   => "#{product.user.armor_user_id}",
    #       'buyer_id'    => "#{current_user.armor_user_id}",
    #       'amount'      => armor_order_params["amount"],
    #       'summary'     => product.name,
    #       'description' => product.description
    #     }
    #
    #     @armor_order.create_armor_api_order(current_user.armor_account_id, api_armor_order_params)
    #
    #     format.html { redirect_to dashboard_orders_path, notice: 'Armor Order was successfully created.' }
    #     format.json { render :show, status: :created, location: @armor_order }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @armor_order.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def update
    respond_to do |format|
      if @armor_order.update(armor_order_params)
        format.html { redirect_to @armor_order, notice: 'Armor order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @armor_order.errors, status: :unprocessable_entity }
      end
    end
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
