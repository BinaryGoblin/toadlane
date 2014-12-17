class Admin::TaxesController < Admin::ApplicationController
  layout 'admin_dashboard'

  before_action :set_tax, only: [:show, :edit, :update, :destroy]

  def index
    @taxes = Tax.all.order('created_at ASC')
  end

  def new
    @tax = Tax.new
  end

  def create
    @tax = Tax.new(tax_params)

    respond_to do |format|
      if @tax.save
        format.html { redirect_to admin_taxes_path, notice: 'Tax was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @tax.update(tax_params)
        format.html { redirect_to admin_taxes_path, notice: 'Tax was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @tax.destroy
    respond_to do |format|
      format.html { redirect_to admin_taxes_path }
    end
  end

  private
    def set_tax
      @tax = Tax.find(params[:id])
    end

    def tax_params
      params.require(:tax).permit(:name, :value)
    end
end
