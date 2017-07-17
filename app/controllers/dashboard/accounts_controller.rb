class Dashboard::AccountsController < DashboardController
  include ProductHelper

  before_filter :authenticate_user!, except: [:callback]
  skip_before_filter :authenticate, only: [:callback]

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
        Services::ActivityTracker.track(current_user, green_profile)

        redirect_to dashboard_accounts_path, flash: { notice: 'Green Profile successfully created.' }
      else
        redirect_to dashboard_accounts_path, flash: { alert: "#{green_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, flash: { alert: 'Green Profile not created, please try again.' }
    end
  end

  def create_amg_profile
    if amg_params.present?
      amg_profile = AmgProfile.new(amg_params)
      if amg_profile.valid?
        current_user.amg_profile = amg_profile
        Services::ActivityTracker.track(current_user, amg_profile)

        redirect_to dashboard_accounts_path, flash: { notice: 'AMG Profile successfully created.' }
      else
        redirect_to dashboard_accounts_path, flash: { alert: "#{amg_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, flash: { alert: 'AMG Profile not created, please try again.' }
    end
  end

  def create_emb_profile
    if emb_params.present?
      emb_profile = EmbProfile.new(emb_params)
      if emb_profile.valid?
        current_user.emb_profile = emb_profile
        Services::ActivityTracker.track(current_user, emb_profile)

        redirect_to dashboard_accounts_path, flash: { notice: 'EMB Profile successfully created.' }
      else
        redirect_to dashboard_accounts_path, flash: { alert: "#{emb_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, flash: { alert: 'EMB Profile not created, please try again.' }
    end
  end

  def create_fly_buy_profile
    address_id = fly_buy_params['address_id']

    if fly_buy_params['address_attributes'].present?
      address_attributes_param = fly_buy_params['address_attributes'][(current_user.addresses.count + 1).to_s]
      empty_keys = address_attributes_param.select {|k, v| v.empty?}

      return redirect_to dashboard_accounts_path, flash: { error: 'You must enter valid address to submitting your profile.' } if !address_id.present? && empty_keys.count > 0
    else
      return redirect_to dashboard_accounts_path, flash: { error: 'You must enter atleast one address to submitting your profile.' } unless address_id.present?
    end

    fly_buy_profile = create_update_fly_buy_profile
    create_and_update_fly_buy_profile_notification(fly_buy_profile)

    if current_user.profile_complete?
      unless current_user.name.present?
        remove_ssn_tin_data(fly_buy_profile)

        return redirect_to dashboard_accounts_path, flash: { account_error: 'You must update your first and last name prior to submitting your company information.' }
      end

      unless current_user.company.present?
        remove_ssn_tin_data(fly_buy_profile)

        return redirect_to dashboard_accounts_path, flash: { account_error: 'You must add your company name prior to submitting your company information.' }
      end
    else
      remove_ssn_tin_data(fly_buy_profile)

      return redirect_to dashboard_accounts_path, flash: { account_error: 'You must complete your profile before you can create a bank account.' }
    end

    if fly_buy_params.present?
      fly_buy_profile.update_attribute(:error_details, {})

      unless address_id.present?
        address = current_user.addresses.last
        address_id = address.id rescue nil
      end

      bank_account_details = {
        bank_name: fly_buy_params['bank_name'],
        address: fly_buy_params['address'],
        name_on_account: fly_buy_params['name_on_account'],
        account_num: fly_buy_params['account_num'],
        routing_num: fly_buy_params['routing_num']
      }
      bank_account_details.merge!(swift: fly_buy_params['additional_information']) if fly_buy_params['additional_information'].present? && fly_buy_profile.outside_the_us?

      FlyAndBuy::CreateUserJob.perform_later(current_user, fly_buy_profile) unless fly_buy_profile.synapse_user_id.present?
      FlyAndBuy::AddCompanyDocumentJob.perform_later(current_user, fly_buy_profile, address_id) unless fly_buy_profile.company_doc_verified?
      FlyAndBuy::AddUserDocumentJob.perform_later(current_user, fly_buy_profile, address_id) if !fly_buy_profile.user_doc_verified? && ['tier_2', 'tier_3'].include?(fly_buy_profile.profile_type)
      FlyAndBuy::AddBankDetailsJob.perform_later(current_user, fly_buy_profile, bank_account_details) unless fly_buy_profile.bank_details_verified?

      UserMailer.send_notification_for_fly_buy_profile(fly_buy_profile, address_id).deliver_later
    end

    fly_buy_profile.update_attribute(:submited, true)

    if session[:redirect_back].present?
      redirect_back = session[:redirect_back]
      session[:redirect_back] = nil

      redirect_to redirect_back
    else
      redirect_to dashboard_accounts_path
    end
  end

  def answer_kba_question
    if request.post? && fly_buy_params.present?
      FlyAndBuy::AnswerKbaQuestions.new(current_user, current_user.fly_buy_profile, fly_buy_params).process

      redirect_to dashboard_accounts_path
    end
  end

  def update
    if params[:green_profile].present?
      green_profile = current_user.green_profile
      green_profile.update_attributes(green_params)

      redirect_to dashboard_accounts_path, flash: { notice: 'Green Profile successfully updated.' }
    elsif params[:amg_profile].present?
      amg_profile = current_user.amg_profile
      amg_profile.update_attributes(amg_params)

      redirect_to dashboard_accounts_path, flash: { notice: 'AMG Profile successfully updated.' }
    elsif params[:emb_profile].present?
      emb_profile = current_user.emb_profile
      emb_profile.update_attributes(emb_params)

      redirect_to dashboard_accounts_path, flash: { notice: 'EMB Profile successfully updated.' }
    end
  end

  def check_valid_phone_number
    phone_number = Phonelib.parse(armor_params['phone'])
    phone_number = phone_number.valid? ? true : false

    respond_to do |format|
      format.json { render json: phone_number }
    end
  end

  def check_valid_state
    state = get_state(params['armor_profile']['addresses']['state'])
    state = state.present? ? true : false

    respond_to do |format|
      format.json { render json: state }
    end
  end

  def callback
    Services::FlyAndBuy::Webhook::Responses.new(params).handle

    render nothing: true, status: 200
  end

  private

  def set_user
    @user = current_user
  end

  def set_green_profile
    @green_profile = current_user.green_profile || GreenProfile.new
  end

  def set_fly_buy_profile
    @fly_buy_profile = current_user.fly_buy_profile || FlyBuyProfile.new
  end

  def set_amg_profile
    @amg_profile = current_user.amg_profile || AmgProfile.new
  end

  def set_emb_profile
    @emb_profile = current_user.emb_profile || EmbProfile.new
  end

  def user_params
    params.require(:user).permit!
  end

  def green_params
    params.require(:green_profile).permit!
  end

  def fly_buy_params
    params.require(:fly_buy_profile).permit!
  end

  def amg_params
    params.require(:amg_profile).permit!
  end

  def emb_params
    params.require(:emb_profile).permit!
  end

  def armor_params
    params.require(:armor_profile).permit!
  end

  def create_update_address(armor_params)
    if armor_params['addresses'].present?
      current_user.addresses.create(armor_params['addresses'])
      selected_address = current_user.addresses.first
    else
      selected_address = current_user.addresses.find_by_id(armor_params[:address_id])
    end
  end

  def create_update_fly_buy_profile
    args = {}
    args[:phone] = fly_buy_params[:company_phone] if fly_buy_params[:company_phone].present?
    if fly_buy_params[:company].present?
      args[:company] = fly_buy_params[:company]
    else
      return redirect_to dashboard_accounts_path, flash: { error: 'Please enter company name.' }
    end
    current_user.update_attributes(args) if args.present?

    if fly_buy_params['address_attributes'].present?
      address_attributes_param = fly_buy_params['address_attributes'][(current_user.addresses.count + 1).to_s]
      empty_keys = address_attributes_param.select {|k, v| v.empty?}

      if empty_keys.count == 5
        fly_buy_params.except!(:address_attributes)
      else
        address = current_user.addresses.create(address_attributes_param)
        fly_buy_params.merge!(address_id: address.id).except!(:address_attributes)
      end
    end

    fly_buy_params['ssn_number'] = fly_buy_params['ssn_number'].gsub(/\*/, '') if fly_buy_params['ssn_number'].present?
    fly_buy_params['tin_number'] = fly_buy_params['tin_number'].gsub(/\*/, '') if fly_buy_params['tin_number'].present?

    necessary_fly_buy_params = fly_buy_params.except(:email, :address_id, :fingerprint, :bank_name, :name_on_account, :account_num, :company)
    necessary_fly_buy_params.merge!(
      synapse_ip_address: request.ip,
      encrypted_fingerprint: generate_encrypted_fingerprint(fly_buy_params['fingerprint']),
      user_id: current_user.id,
      company_email: fly_buy_params['email'],
      error_details: {}
    )

    if current_user.fly_buy_profile.present?
      fly_buy_profile = current_user.fly_buy_profile
      fly_buy_profile.update_attributes(necessary_fly_buy_params)
    else
      fly_buy_profile = FlyBuyProfile.create(necessary_fly_buy_params)
    end

    fly_buy_profile
  end

  def remove_ssn_tin_data(fly_buy_profile)
    fly_buy_profile.update_attributes(ssn_number: nil, tin_number: nil)
  end

  def create_and_update_fly_buy_profile_notification(fly_buy_profile)
    if fly_buy_profile.fly_buy_profile_notification.present?
      fly_buy_profile.fly_buy_profile_notification.update_attributes(
        invalid_tin: false,
        invalid_ssn: false,
        mfa_pending_tin: false,
        mfa_pending_ssn: false
      )
    else
      FlyBuyProfileNotification.create(fly_buy_profile_id: fly_buy_profile.id)
    end
  end
end
