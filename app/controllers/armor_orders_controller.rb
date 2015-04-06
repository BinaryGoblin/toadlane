class ArmorOrdersController < ApplicationController
  before_action :set_armor_order, only: [:show, :edit, :update, :destroy]

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
    client = ArmorService.new.client
    product = Product.find(armor_order_params[:product_id])

    api_armor_order_params = { 
      'seller_id'   => "#{product.user.armor_profile.armor_user_id}",
      'buyer_id'    => "#{current_user.armor_profile.armor_user_id}",
      'amount'      => armor_order_params["amount"],
      'summary'     => armor_order_params["summary"],
      'description' => armor_order_params["description"]
    }
    
    client.orders(current_user.armor_profile.armor_account_id).create(api_armor_order_params)

    additional_params = {
      buyer_id: current_user.armor_profile.armor_user_id,
      seller_id: product.user.armor_profile.armor_user_id,
      product_id: product.id,
      status_change: DateTime.now,
      account_id: current_user.armor_profile.armor_account_id
    }

    @armor_order = ArmorOrder.new(armor_order_params.merge(additional_params))

    respond_to do |format|
      if @armor_order.save
        format.html { redirect_to dashboards_orders_path, notice: 'Armor Order was successfully created.' }
        format.json { render :show, status: :created, location: @armor_order }
      else
        format.html { render :new }
        format.json { render json: @armor_order.errors, status: :unprocessable_entity }
      end
    end
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
