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
    product = Product.find(armor_order_params[:product_id])

    seller_id = product.user.armor_profile.armor_user
    buyer_id = current_user.armor_profile.armor_user
    
    invoice = ArmorInvoice.new( buyer_id: buyer_id,
                                seller_id: seller_id,
                                product_id: product.id,
                                unit_price: armor_order_params[:unit_price],
                                count: armor_order_params[:count],
                                taxes_price: armor_order_params[:taxes_price],
                                rebate_price: armor_order_params[:rebate_price],
                                rebate_percent: armor_order_params[:rebate_percent],
                                amount: armor_order_params[:amount],
                                user_id: current_user.id
    )

    if invoice.save 
      # step1 - save order in 'pre-request'
      order = ArmorOrder.new( buyer_id: invoice.buyer_id,
                              seller_id: invoice.seller_id,
                              product_id: invoice.product_id,
                              amount: invoice.amount,
                              count: invoice.count,
                              summary: armor_order_params[:summary],
                              description: armor_order_params[:description],
                              invoice_num: invoice.id,
                              purchase_order_num: invoice.id,    
                              status_change: DateTime.now )

      if order.save
        armor_seller_account = order.product.user.armor_profile.armor_account
        data = ArmorService.new

        params = { 'account'     => armor_seller_account.to_s,
                   'seller_id'   => order.seller_id.to_s,
                   'buyer_id'    => order.buyer_id.to_s,
                   'amount'      => order.amount.to_s,
                   'summary'     => order.summary.to_s,
                   'description' => order.description,
                   'invoice_no'  => order.invoice_num.to_s,
                   'po_no'       => order.purchase_order_num.to_s,
                   'message'     => "message" }

        armor_order = data.create_order(params)
        if armor_order["order_id"].present?
          data = ArmorOrder.new( order_id: armor_order["order_id"],
                                 account_id: armor_order["account_id"],
                                 status: armor_order["status"],
                                 amount: armor_order["amount"],
                                 summary: armor_order["summary"],
                                 description: armor_order["description"],
                                 invoice_num: armor_order["invoice_num"],
                                 purchase_order_num: armor_order["purchase_order_num"],
                                 status_change: armor_order["status_change"],
                                 uri: armor_order["url"] )
          if data.save
            data.update( buyer_id: invoice.buyer_id, 
                         seller_id: invoice.seller_id, 
                         product_id: invoice.product_id, 
                         unit_price: invoice.unit_price,
                         count: invoice.count )
          end
        end
      end
    end

    redirect_to dashboards_invoices_path
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
