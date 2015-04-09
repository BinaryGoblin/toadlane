class Admin::ResellersController < Admin::ApplicationController
  layout 'admin_dashboard'

  before_action :set_reseller, only: [:update, :destroy, :get_certificate]

  def index
    @resellers = Role.find_by(name: :user).users.order('id ASC')
  end

  def update
    respond_to do |format|
      if @reseller.update(is_reseller: true)
        format.html { redirect_to admin_resellers_path, notice: 'Reseller was successfully updated.' }
      else
        format.html { render action: 'index' }
      end
    end
  end

  def destroy
    respond_to do |format|
    if @reseller.update(is_reseller: false)
        format.html { redirect_to admin_resellers_path, notice: 'Reseller was successfully updated.' }
      else
        format.html { render action: 'index' }
      end
    end
  end
  
  def get_certificate
    send_data @reseller.certificate.data, :filename => @reseller.certificate.filename, :type => @reseller.certificate.content_type
  end

  private
    def set_reseller
      @reseller = User.find(params[:id])
    end
end
