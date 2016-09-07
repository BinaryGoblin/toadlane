class Admin::FeesController < Admin::ApplicationController
  layout 'admin_dashboard'

  before_action :set_fee, only: [:show, :edit, :update, :destroy]

  def index
    @fees = Fee.all.order('created_at ASC')
  end

  def new
    @fee = Fee.new
  end

  def create
    @fee = Fee.new(fee_params)

    respond_to do |format|
      if @fee.save
        format.html { redirect_to admin_fees_path, notice: 'Fee was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @fee.update(fee_params)
        format.html { redirect_to admin_fees_path, notice: 'Fee was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @fee.destroy
    respond_to do |format|
      format.html { redirect_to admin_fees_path }
    end
  end

  private
    def set_fee
      @fee = Fee.find(params[:id])
    end

    def fee_params
      params.require(:fee).permit(:module_name, :value, :fee_type)
    end
end
