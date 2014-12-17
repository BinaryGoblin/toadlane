class ArmorInvoicesController < ApplicationController
  before_action :set_armor_invoice, only: [:show, :edit, :update, :destroy]

  def index
    @armor_invoices = ArmorInvoice.all
  end

  def show
  end

  def destroy
    @armor_invoice.destroy
    respond_to do |format|
      format.html { redirect_to armor_invoices_url }
      format.json { head :no_content }
    end
  end

  private
    def set_armor_invoice
      @armor_order = ArmorInvoice.find(params[:id])
    end

    def armor_invoice_params
      params.require(:armor_invoice).permit!
#(:seller_id, :buyer_id, :order_id, :account_id, :status, :amount, :summary, :description, :invoice_num, :purchase_order_num, :status_change, :uri)
    end
end
