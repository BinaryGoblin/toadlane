class Dashboard::ProfilesController < DashboardController
  before_action :set_user, only: [:show, :update, :update_i_buy_and_sell]

  def show
    session[:previous_url] = request.referrer
    @user = current_user
    @subcategory = Category.all.where.not(parent_id: nil)

    if params["req_company"] == "true"
      @user.errors.add(:company, 'is required')
    elsif params["req_name"] == "true"
      @user.errors.add(:name, 'must have first and last name')
    end
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
        if session[:previous_url].present? && session[:previous_url] != products_url
          previous_visited_url = session[:previous_url]
          session.delete(:previous_url)
          format.html { redirect_to previous_visited_url, :flash => { :notice => 'Congratulations! You are ready to place an order!'} }
        else
          format.html { redirect_to dashboard_profile_path(saved?: true), :flash => { :notice => 'Your profile details has been saved successfully.'} }
        end
      else
        format.html { render action: 'show' }
      end
    end
  end

  def update_i_buy_and_sell
    @user.tag_list = params[:user][:tag_list]
    if @user.save(:validate => false)
      flash[:notice] = 'I Buy and Sell information added successfully.'
      redirect_to products_url
    else
      redirect_to dashboard_profile_path
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
