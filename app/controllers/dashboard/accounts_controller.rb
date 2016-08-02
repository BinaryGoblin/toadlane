class Dashboard::AccountsController < DashboardController
  def index
    set_user
    set_green_profile
    set_amg_profile
  end

  def create_green_profile
    if green_params.present?
      green_profile = GreenProfile.new(green_params)
      if green_profile.valid?
        current_user.green_profile = green_profile
        redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully created." }
      else
        redirect_to dashboard_accounts_path, :flash => { :alert => "#{green_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, :flash => { :alert => "Green Profile not created, please try again." }
    end
  end

  def create_amg_profile
    if amg_params.present?
      amg_profile = AmgProfile.new(amg_params)
      if amg_profile.valid?
        current_user.amg_profile = amg_profile
        redirect_to dashboard_accounts_path, :flash => { :notice => "AMG Profile successfully created." }
      else
        redirect_to dashboard_accounts_path, :flash => { :alert => "#{amg_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, :flash => { :alert => "AMG Profile not created, please try again." }
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

    def set_amg_profile
      current_amg_profile = current_user.amg_profile
      if current_amg_profile.present?
        @amg_profile = current_amg_profile
      else
        @amg_profile = AmgProfile.new
      end
    end

    def user_params
      params.require(:user).permit!
    end

    def green_params
      params.require(:green_profile).permit!
    end

    def amg_params
      params.require(:amg_profile).permit!
    end
end
