class Dashboard::ProfilesController < DashboardController
  before_action :set_user, only: [:show, :update]

  def show
    if !current_user.profile_complete?
      session[:previous_url] = request.referrer
    end
    @user = current_user
  end

  def update
    user_params[:password] = user_params[:new_password]
    user_params[:password_confirmation] = user_params[:new_password_confirmation]

    user_params.except!(:new_password, :new_password_confirmation)

    if user_params[:password].blank? && user_params[:password_confirmation].blank?
      user_params.delete(:password)
      user_params.delete(:password_confirmation)
    end

    if user_params[:delete_asset].present? && user_params[:delete_asset] == 'on'
      @user.update(asset_file_name: nil, asset_file_size: nil, asset_content_type: nil)
      user_params.delete(:delete_asset)
    end

    if user_params[:certificate].present?
      if @user.certificate
        @user.certificate.update(uploaded_file: user_params[:certificate])
      else
        certificate = Certificate.new
        certificate.uploaded_file = user_params[:certificate]
        @user.certificate = certificate
      end

      user_params.delete(:certificate)
    end

    if user_params[:certificate_delete].present?
      current_user.certificate.destroy
      user_params.delete(:certificate_delete)
    end

    respond_to do |format|
      if @user.update(user_params)
        if current_user.profile_complete? && session[:previous_url].present?
          previous_visited_url = session[:previous_url]
          session.delete(:previous_url)
          format.html { redirect_to previous_visited_url, :flash => { :notice => 'Your profile details has been saved successfully.'} }
        else
          format.html { redirect_to dashboard_profile_path(saved?: true) }
        end
      else
        format.html { render action: 'show' }
      end
    end
  end

  private
  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit!
  end
end
