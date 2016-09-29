class Dashboard::AccountsController < DashboardController
  include ProductHelper
  def index
    set_user
    set_green_profile
    set_amg_profile
    set_emb_profile
    set_fly_buy_profile
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

  def create_fly_buy_profile
    if request.post? && fly_buy_params.present?
      fly_buy_params.merge!(ip_address: '192.168.0.112')
      @oauth_key = FlyAndBuy::UserOperations.new(current_user, fly_buy_params).create_user
      @fingerprint = current_user.fly_buy_profile.encrypted_fingerprint
      @development_mode = Rails.env.production? ? false : true
      redirect_to dashboard_accounts_path
    end
  end

  def create_promise_account
    if current_user.present? && !current_user.profile_complete?
      return redirect_to dashboard_accounts_path, :flash => { :account_error => "You must complete your profile before you can create a bank account." }
    end

    promise_pay_instance = PromisePayService.new

    address = current_user.addresses.first
    phone_number = Phonelib.parse(current_user.phone)
    country = IsoCountryCodes.find(address.country)
    all_user_ids = promise_pay_instance.client.users.find_all.map &:id
    if all_user_ids.include? current_user.id.to_s
      user = promise_pay_instance.client.users.find(current_user.id)
    else
      user = promise_pay_instance.client.users.create(
              id: current_user.id,
              first_name: current_user.first_name,
              last_name: current_user.last_name,
              email: current_user.email,
              company: current_user.company,
              mobile: phone_number.international,
              address: address.line1,
              city: address.city,
              state: address.state,
              zip: address.zip,
              country: country.alpha3
            )
    end

    country_for_bank = IsoCountryCodes.find(promise_params['country'])

    bank_account = promise_pay_instance.client.bank_accounts.create(
      user_id: user.id,
      bank_name: promise_params['bank_name'],
      account_name: promise_params['account_name'],
      routing_number: promise_params['routing_number'],
      account_number: promise_params['account_number'],
      account_type: promise_params['account_type'],
      holder_type: promise_params['holder_type'],
      country: country_for_bank.alpha3
    )

    direct_debit_agreement = promise_params["direct_debit_agreement"] == "1"

    PromiseAccount.create({
      user_id: current_user.id,
      bank_account_id: bank_account.id,
      direct_debit_agreement: direct_debit_agreement
    })

    if current_user.promise_account.present? && current_user.promise_account.bank_account_id.present?
      flash[:notice] = "Bank Account was successfully added."
    else
      flash[:alert] = "There was some problem adding bank account."
    end
    redirect_to request.referrer
  rescue Promisepay::UnprocessableEntity => e
    flash[:error] = e.message
    redirect_to request.referrer
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

  def create_emb_profile
    if emb_params.present?
      emb_profile = EmbProfile.new(emb_params)
      if emb_profile.valid?
        current_user.emb_profile = emb_profile
        redirect_to dashboard_accounts_path, :flash => { :notice => "EMB Profile successfully created." }
      else
        redirect_to dashboard_accounts_path, :flash => { :alert => "#{emb_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, :flash => { :alert => "EMB Profile not created, please try again." }
    end
  end

  def update
    if params[:green_profile].present?
      green_profile = current_user.green_profile
      green_profile.update_attributes(green_params)
      redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully updated." }
    elsif params[:amg_profile].present?
      amg_profile = current_user.amg_profile
      amg_profile.update_attributes(amg_params)
      redirect_to dashboard_accounts_path, :flash => { :notice => "AMG Profile successfully updated." }
    elsif params[:emb_profile].present?
      emb_profile = current_user.emb_profile
      emb_profile.update_attributes(emb_params)
      redirect_to dashboard_accounts_path, :flash => { :notice => "EMB Profile successfully updated." }
    end
  end

  def set_armor_profile
    current_armor_profile = current_user.armor_profile
    if current_armor_profile.present?
      armor_profile = current_armor_profile
    elsif params[:confirmed_email].present? && current_armor_profile.nil?
      armor_profile = ArmorProfile.create(:confirmed_email => params[:confirmed_email], :user_id => current_user.id)
    else
      armor_profile = ArmorProfile.new
    end

    if params[:product_id].present? && params[:armor_order_id].present?
      redirect_to product_checkout_path(product_id: params[:product_id], armor_order_id: params[:armor_order_id], armor_profile_id: armor_profile.id), :flash => { :notice => "Your email has been confirmed successfully. fill up other details to create armor profile" }
    else
      redirect_to dashboard_accounts_path(armor_profile_id: armor_profile.id), :flash => { :notice => "Your email has been confirmed successfully. fill up other details to create armor profile" }
    end
  end

  # for valid phone number
  def check_valid_phone_number
    phone_number = Phonelib.parse(armor_params['phone'])
    if phone_number.valid?
      phone_number = true
    else
      phone_number = false
    end

    respond_to do |format|
      format.json { render :json => phone_number }
    end
  end

  # for valid state
  def check_valid_state
    state = get_state(params['armor_profile']['addresses']['state'])

    if state.present?
      state = true
    else
      state = false
    end

    respond_to do |format|
      format.json { render :json => state }
    end
  end

  def callback
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

  def set_fly_buy_profile
    current_fly_buy_profile = current_user.fly_buy_profile
    if current_fly_buy_profile.present?
      @fly_buy_profile = current_fly_buy_profile
    elsif params['fly_buy_profile_id'].present?
      @fly_buy_profile = FlyBuyProfile.find_by_id(params['fly_buy_profile_id'])
    else
      @fly_buy_profile = FlyBuyProfile.new
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

  def fly_buy_params
    params.require(:fly_buy_profile).permit!
  end

  def create_update_address(armor_params)
    if armor_params['addresses'].present?
      current_user.addresses.create(armor_params['addresses'])
      selected_address = current_user.addresses.first
    else
      selected_address = current_user.addresses.find_by_id(armor_params[:address_id])
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

  def set_emb_profile
    current_emb_profile = current_user.emb_profile
    if current_emb_profile.present?
      @emb_profile = current_emb_profile
    else
      @emb_profile = EmbProfile.new
    end
  end

  def user_params
    params.require(:user).permit!
  end

  def amg_params
    params.require(:amg_profile).permit!
  end

  def emb_params
    params.require(:emb_profile).permit!
  end
end
