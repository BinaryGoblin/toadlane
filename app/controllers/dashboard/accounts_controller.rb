class Dashboard::AccountsController < DashboardController
  include ProductHelper

  before_filter :authenticate_user!, except: [:callback]

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
    fly_buy_profile = create_update_flybuy_profile
    
    if current_user.present? && current_user.profile_complete? == false
      return redirect_to dashboard_accounts_path, :flash => { :account_error => "You must complete your profile before you can create a bank account." }
    end

    if current_user.present? && current_user.profile_complete? && current_user.name.present? && current_user.name.count(" ") == 0
      return redirect_to dashboard_accounts_path, :flash => { :account_error => "You must update your first and last name prior to submitting your company information" }
    end

    if current_user.present? && current_user.profile_complete? && current_user.company.present? == false
      return redirect_to dashboard_accounts_path, :flash => { :account_error => "You must add your company name prior to submitting your company information." }
    end

    if request.post? && fly_buy_params.present?
      bank_account_details = {
        bank_name: fly_buy_params["bank_name"],
        address: fly_buy_params["address"],
        name_on_account: fly_buy_params["name_on_account"],
        account_num: fly_buy_params["account_num"],
        routing_num: fly_buy_params["routing_num"],
        address_id: fly_buy_params["address_id"]
      }

      if fly_buy_profile.synapse_user_id.present?
        AddBankDetailsForFlyBuyJob.perform_later(current_user.id, fly_buy_profile.id, bank_account_details)
      else 
        CreateUserForFlyBuyJob.perform_later(current_user.id, fly_buy_profile.id)
        AddBankDetailsForFlyBuyJob.perform_later(current_user.id, fly_buy_profile.id, bank_account_details)
      end

      fly_buy_profile.update_attribute(:completed, true)
      redirect_to dashboard_accounts_path
    end
  rescue SynapsePayRest::Error::Conflict => e
    puts e
    flash[:error] = e
    redirect_to dashboard_accounts_path
  end

  def answer_kba_question
    if request.post? && fly_buy_params.present?
      fly_buy_profile = current_user.fly_buy_profile
      FlyAndBuy::AnswerKbaQuestions.new(current_user, fly_buy_profile, fly_buy_params).process
      fly_buy_profile.update_attribute(:completed, true)
      redirect_to dashboard_accounts_path
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
    # Handled wehbook for when the status of the transaction is "SETTLED"
    if params["account"].present?
      if params["account"]["extra"]["note"] == "Transaction Created"
        synapse_transaction_id = params["_id"]["$oid"]
        fly_buy_order = FlyBuyOrder.find_by_synapse_transaction_id(synapse_transaction_id)
      elsif params["account"]["extra"]["note"] == "Released Payment" && params["account"]["extra"]["supp_id"].present?
        fly_buy_order_id = params["account"]["extra"]["supp_id"].split("_").last
        fly_buy_order = FlyBuyOrder.find_by_id(fly_buy_order_id)
      end

      if fly_buy_order.present? && params["recent_status"]["status"] == "SETTLED" && params["recent_status"]["status_id"] == "4"
        if params["account"]["extra"]["note"] == "Transaction Created"
          fly_buy_order.update_attributes({
            status: 'pending_inspection',
            funds_in_escrow: true
          })
          UserMailer.send_funds_received_notification_to_seller(fly_buy_order).deliver_later
          UserMailer.send_transaction_settled_notification_to_buyer(fly_buy_order).deliver_later
        elsif params["account"]["extra"]["note"] == "Released Payment"
          fly_buy_order.update_attributes({
            payment_release: true,
            status: 'completed'
           })
          UserMailer.send_payment_released_notification_to_seller(fly_buy_order).deliver_later
        end
      elsif fly_buy_order.present? && params["recent_status"]["status"] == "QUEUED-BY-SYNAPSE"
        fly_buy_order.update_attribute(:status, 'queued')
        UserMailer.send_order_queued_notification_to_seller(fly_buy_order).deliver_later
        UserMailer.send_order_queued_notification_to_buyer(fly_buy_order).deliver_later
      end
    end
    # Handling webhook for if permission status is 'SEND-AND-RECEIVE'
    if params["documents"].present?
      if params["_id"]["$oid"].present? && params["permission"] == "SEND-AND-RECEIVE"
        permission_array = params["permission"].split('-')
        synapse_user_id = params["_id"]["$oid"]
        fly_buy_profile = FlyBuyProfile.find_by_synapse_user_id(synapse_user_id)
        if fly_buy_profile.present? && fly_buy_profile.created_at.to_date > Date.today
          fly_buy_profile.destroy
        end
        if fly_buy_profile.present? && permission_array.include?('SEND') && permission_array.include?('RECEIVE')
          fly_buy_profile.update_attributes({
            permission_scope_verified: true,
            kba_questions: {}
          })
          UserMailer.send_account_verified_notification_to_user(fly_buy_profile).deliver_later
        else
          UserMailer.send_account_not_verified_yet_notification_to_user(fly_buy_profile).deliver_later
        end
      elsif params["_id"]["$oid"].present? && params["documents"][1]["virtual_docs"][0]["status"] == "SUBMITTED|INVALID"
        # This is for SSN entered `1111` and is not valid
        synapse_user_id = params["_id"]["$oid"]
        fly_buy_profile = FlyBuyProfile.find_by_synapse_user_id(synapse_user_id)

        if fly_buy_profile.present?
          fly_buy_profile.update_attributes({
            permission_scope_verified: false,
            kba_questions: {},
            completed: false
          })
          UserMailer.send_ssn_num_not_valid_notification_to_user(fly_buy_profile).deliver_later
        end
      elsif params["_id"]["$oid"].present? && params["documents"][1]["virtual_docs"][0]["status"] == "SUBMITTED|MFA_PENDING"
        # this is for SSN `3333`
        synapse_user_id = params["_id"]["$oid"]
        fly_buy_profile = FlyBuyProfile.find_by_synapse_user_id(synapse_user_id)

        if fly_buy_profile.present?
          questions = params["documents"][1]["virtual_docs"][0]["meta"]
          fly_buy_profile.update_attributes({
            permission_scope_verified: false,
            kba_questions: questions,
            completed: false
          })
          UserMailer.send_ssn_num_partially_valid_notification_to_user(fly_buy_profile).deliver_later
        end
      end
    end
    render nothing: true, status: 200
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

  def create_update_flybuy_profile
    if fly_buy_params["address_attributes"].present?
      address_attributes_param = fly_buy_params["address_attributes"][(current_user.addresses.count + 1).to_s]
      empty_keys = address_attributes_param.select {|k, v| v.empty?}
      if empty_keys.count == 5
        fly_buy_params.except!(:address_attributes)
      else
        address = current_user.addresses.create(address_attributes_param)
        fly_buy_params.merge!(address_id: address.id).except!(:address_attributes)
      end
    end

    current_user.update_attribute(:phone, fly_buy_params["company_phone"])

    if current_user.fly_buy_profile.present?
      fly_buy_profile = FlyBuyProfile.where(user_id: current_user.id).first
      necessary_fly_buy_params = fly_buy_params.except(
                                    :email, :address_id,
                                    :fingerprint, :bank_name,
                                    :name_on_account, :account_num
                                  )

      necessary_fly_buy_params.merge!(
        synapse_ip_address: request.ip,
        encrypted_fingerprint: "user_#{current_user.id}" + "_" + fly_buy_params["fingerprint"],
        user_id: current_user.id, company_email: fly_buy_params["email"]
      )

      fly_buy_profile.update(necessary_fly_buy_params)
    else

      necessary_fly_buy_params = fly_buy_params.except(
                                    :email, :address_id,
                                    :fingerprint, :bank_name,
                                    :name_on_account, :account_num
                                  )

      necessary_fly_buy_params.merge!(
        synapse_ip_address: request.ip,
        encrypted_fingerprint: "user_#{current_user.id}" + "_" + fly_buy_params["fingerprint"],
        user_id: current_user.id,
        company_email: fly_buy_params["email"]
      )

      fly_buy_profile = FlyBuyProfile.create(necessary_fly_buy_params)
    end
    fly_buy_profile
  end
end
