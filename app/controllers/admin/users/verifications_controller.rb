class Admin::Users::VerificationsController < Admin::UsersController
  def index
    @users = User.paginate(page: params[:page], per_page: params[:count]).order('id ASC')
  end
  
  def edit
    set_user
  end

  def update
    set_user
    respond_to do |format|
      if @user.update(is_reseller: true)
        format.html { redirect_to admin_users_verifications_path, notice: 'User was successfully verified.' }
      else
        format.html { render action: 'index' }
      end
    end
  end

  def destroy
    set_user
    respond_to do |format|
      if @user.update(is_reseller: false)
        format.html { redirect_to admin_users_verifications_path, notice: 'User verification removed.' }
      else
        format.html { render action: 'index' }
      end
    end
  end
  
  def get_certificate
    set_user
    send_data @user.certificate.data, :filename => @user.certificate.filename, :type => @user.certificate.content_type
  end
  
  private
    def set_user
      @user = User.find(params[:id])
    end
end
