class Dashboard::AccountsController < DashboardController
  include ProductHelper

  def index
    set_user
    set_green_profile
    set_profile_for_armor
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
    agreed_terms = params["armor_profile"]["agreed_terms"] == "1" ? true : false
    current_user.armor_profile.update_attribute(:agreed_terms, agreed_terms)

    account_data = {
                      "company" => current_user.company,
                      "user_name" => current_user.name,
                      "user_email" => current_user.email,
                      "user_phone" => current_user.phone,
                      "address" => current_user.addresses.first.line1,
                      "city" => current_user.addresses.first.city,
                      # "state" => get_state(current_user.addresses.first.state) || current_user.addresses.first.state,
                      "state" => "CA",
                      "zip" => current_user.addresses.first.zip,
                      "country" => current_user.addresses.first.country.downcase,
                      "email_confirmed" => email_confirmed,
                      "agreed_terms" => agreed_terms }

    result = client.accounts.create(account_data)
    current_user.armor_profile.update_attribute(:armor_account_id, result.data[:body]["account_id"])

    users = client.users(current_user.armor_profile.armor_account_id).all
    current_user.armor_profile.update_attribute(:armor_user_id, users.data[:body][0]["user_id"].to_i)

    redirect_to dashboard_accounts_path, :flash => { :notice => "Armor Profile successfully created." }
  rescue ArmorService::BadResponseError => e
    redirect_to dashboard_accounts_path, :flash => { :error => e.errors.values.flatten }
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

  def set_armor_profile
    current_armor_profile = current_user.armor_profile
    if current_armor_profile.present?
      @armor_profile = current_armor_profile
    elsif params[:confirmed_email].present? && current_armor_profile.nil?
      @armor_profile = ArmorProfile.create(:confirmed_email => params[:confirmed_email], :user_id => current_user.id)
    else
      @armor_profile = ArmorProfile.new
    end
    redirect_to dashboard_accounts_path(armor_profile_id: @armor_profile)
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

    def set_profile_for_armor
      current_green_profile = current_user.green_profile
      if current_green_profile.present?
        @green_profile = current_green_profile
      elsif params["armor_profile_id"].present?
        @armor_profile = ArmorProfile.find_by_id(params["armor_profile_id"])
      else
        @armor_profile = ArmorProfile.new
      end
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
