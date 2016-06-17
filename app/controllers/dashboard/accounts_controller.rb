class Dashboard::AccountsController < DashboardController
  def index
    set_user
    set_green_profile
  end

  def create_green_profile
    if green_params.present?
      current_user.green_profile = GreenProfile.new(green_params)
      redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully created." }
    else
      redirect_to dashboard_accounts_path, :flash => { :alert => "Green Profile not created, please try again." }
    end
  end

  def update
    if green_params.present?
      green_profile = current_user.green_profile
      green_profile.update_attributes(green_params)
      redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully updated." }
    end
  end

  private
    def set_user
      @user = current_user
    end

    def set_green_profile
      current_green_profile = current_user.green_profile
      if current_green_profile.present?
        @green_profile = current_green_profile
      else
        @green_profile = GreenProfile.new
      end
    end

    def user_params
      params.require(:user).permit!
    end

    def green_params
      params.require(:green_profile).permit!
    end
end