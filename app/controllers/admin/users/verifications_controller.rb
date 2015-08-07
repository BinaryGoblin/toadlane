class Admin::Users::VerificationsController < Admin::UsersController
  before_action :set_user, only: [:update, :destroy, :get_certificate]

  def index
    @users = Role.find_by(name: :user).users.paginate(page: params[:page], per_page: params[:count]).order('id ASC')
  end

  def update
    respond_to do |format|
      if @user.update(is_reseller: true)
        format.html { redirect_to admin_users_verifications_path, notice: 'User was successfully verified.' }
      else
        format.html { render action: 'index' }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.update(is_reseller: false)
        format.html { redirect_to admin_users_verificationss_path, notice: 'User verification removed.' }
      else
        format.html { render action: 'index' }
      end
    end
  end
  
  def get_certificate
    send_data @user.certificate.data, :filename => @user.certificate.filename, :type => @user.certificate.content_type
  end
end
