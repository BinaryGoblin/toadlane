class Dashboard::AccountsController < DashboardController
  def index
    set_user
    set_green_profile
    set_armor_profile
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

  def create_armor_profile
    client = ArmorService.new
    email_confirmed = params["armor_profile"]["confirmed_email"]
    agreed_terms = params["armor_payments_terms"] == "on" ? true : false

    binding.pry
    account_data = {
                      "company" => current_user.company,
                      "user_name" => current_user.name,
                      "user_email" => current_user.email,
                      "user_phone" => current_user.phone,
                      "address" => current_user.addresses.first.line1,
                      "city" => current_user.addresses.first.city,
                      "state" => "CA",
                      "zip" => current_user.addresses.first.zip,
                      "country" => current_user.addresses.first.country.lowercase,
                      "email_confirmed" => email_confirmed,
                      "agreed_terms" => agreed_terms }

    result = client.accounts.create(account_data)
    # if green_params.present?
    #   green_profile = GreenProfile.new(green_params)
    #   if green_profile.valid?
    #     current_user.green_profile = green_profile
    #     redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully created." }
    #   else
    #     redirect_to dashboard_accounts_path, :flash => { :alert => "#{green_profile.errors.full_messages.to_sentence}" }
    #   end
    # else
    #   redirect_to dashboard_accounts_path, :flash => { :alert => "Green Profile not created, please try again." }
    # end
  end

  def send_confirmation_email
    email = UserMailer.send_confirmation_email(current_user).deliver_now
    redirect_to dashboard_accounts_path, :flash => { :notice => "Confirmation email has been sent. Please check your email." }
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

    def set_armor_profile
      @armor_profile = ArmorProfile.new
    end

    def user_params
      params.require(:user).permit!
    end

    def green_params
      params.require(:green_profile).permit!
    end

    def armor_params
      params.require(:armor_profile).permit!
    end
end
