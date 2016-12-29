class FlyAndBuy::ReleasePaymentToAdditionalSellers

	attr_accessor  :client, :initial_seller_fly_buy_profile, :client_user,
                    :fly_buy_order, :initial_seller, :group

	def initialize(initial_seller, initial_seller_fly_buy_profile, fly_buy_order)
    @initial_seller = initial_seller
		@initial_seller_fly_buy_profile = initial_seller_fly_buy_profile
		@fly_buy_order = fly_buy_order
    @group = @fly_buy_order.seller_group
		@client = FlyBuyService.get_client
		FlyBuyService.create_subscription
	end

	def process
		create_transaction_process
	end


	private

	def create_transaction_process
    get_user_and_instantiate_user

    create_transaction_response = create_transcation

		if create_transaction_response["recent_status"]["note"] == "Transaction created"
      release_payment_to_additional_sellers
			# update_fly_buy_order(create_transaction_response)

			# update_product_count

			# send_email_notification
		end
	end

	def get_user_and_instantiate_user
    user_response = client.users.get(user_id: initial_seller_fly_buy_profile.synapse_user_id)

    client_user = FlyBuyService.get_user(
                      oauth_key: nil,
                      fingerprint: initial_seller_fly_buy_profile.encrypted_fingerprint,
                      ip_address: initial_seller_fly_buy_profile.synapse_ip_address,
                      user_id: initial_seller_fly_buy_profile.synapse_user_id
                  )

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => initial_seller_fly_buy_profile.encrypted_fingerprint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    @client_user =  FlyBuyService.get_user(
                      oauth_key: oauth_response["oauth_key"],
                      fingerprint: initial_seller_fly_buy_profile.encrypted_fingerprint,
                      ip_address: initial_seller_fly_buy_profile.synapse_ip_address,
                      user_id: initial_seller_fly_buy_profile.synapse_user_id
                  )
  end

  def create_transcation
    if Rails.env.development?
      webhook_url = Rails.application.secrets['SYNAPSEPAY_WEBHOOK_URL']
    else
      webhook_url = ENV['SYNAPSEPAY_WEBHOOK_URL']
    end

    total_fee_of_group = group_total_fee_amount(fly_buy_order, group)

    file = convert_invoice_to_image

    trans_payload = {
      "to" => {
        "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:synapse_us],
        "id" => FlyBuyProfile::EscrowNodeID
      },
      "amount" => {
        "amount" => total_fee_of_group,
        "currency" => FlyAndBuy::AddingBankDetails::SynapsePayCurrency
      },
      "extra" => {
        "note" => "Transaction Created for paying to group members",
        "webhook" => webhook_url,
        "process_on" => 0,
        "ip" => initial_seller_fly_buy_profile.synapse_ip_address,
        "other" => {
          "attachments" => [
            encode_attachment(file_tempfile: file.path, file_type: 'image/png')
          ]
        }
      },
    }

    client_user.trans.create(node_id: initial_seller_fly_buy_profile.synapse_node_id, payload: trans_payload)

  end

  def release_payment_to_additional_sellers
    if Rails.env.development?
      webhook_url = Rails.application.secrets['SYNAPSEPAY_WEBHOOK_URL']
    else
      webhook_url = ENV['SYNAPSEPAY_WEBHOOK_URL']
    end
    a = 0

    file = convert_invoice_to_image
    user_response = client.users.get(user_id: FlyBuyProfile::AppUserId)

    client_app_user = FlyBuyService.get_user(oauth_key: nil, fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: initial_seller_fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => FlyBuyProfile::AppFingerPrint
    }

    oauth_response = client_app_user.users.refresh(payload: oauth_payload)

    client_app_user = FlyBuyService.get_user(oauth_key: oauth_response["oauth_key"], fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: initial_seller_fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

    fly_buy_order.product.additional_sellers.each do |add_seller|
      add_seller_total_fee = additional_seller_total_fee_amount(fly_buy_order, group, add_seller)

      trans_payload = {
        "to" => {
          "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:wire],
          "id" => add_seller.fly_buy_profile.synapse_node_id
        },
        "from" => {
          "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:synapse_us],
          "id" => FlyBuyProfile::EscrowNodeID
        },
        "amount" => {
          "amount" => add_seller_total_fee.to_f,
          "currency" => FlyAndBuy::AddingBankDetails::SynapsePayCurrency
        },
        "extra" => {
          "supp_id" => fly_buy_order.class.name + "_" + fly_buy_order.id.to_s,
          "note" => "Released Payment To Additional Seller",
          "webhook" => webhook_url,
          "process_on" => 0,
          "ip" => add_seller.fly_buy_profile.synapse_ip_address,
          "other" => {
            "attachments" => [
              encode_attachment(file_tempfile: file.path, file_type: 'image/png')
            ]
          }
        },
      }

      release_payment = client_app_user.trans.create(node_id: FlyBuyProfile::EscrowNodeID, payload: trans_payload)

      if release_payment["recent_status"]["note"] == "Transaction created"
        a = a + 1
      end
      
    end
    # if group.group_sellers.count == a
    #   fly_buy_order.update_attribute(:payment_released_to_group, true)
    # end
  end

  def send_email_notification
    UserMailer.sales_order_notification_to_seller(fly_buy_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(fly_buy_order).deliver_later
  end

	def convert_invoice_to_image
    html = ActionController::Base.new.send(:render_to_string,
                                :partial => 'shared/invoice',
                                :locals => {order: fly_buy_order, :user => initial_seller},
                                :layouts => 'layouts/print.html.slim')

    kit = IMGKit.new(html)
    img = kit.to_png
    file  = Tempfile.new(["template_#{fly_buy_order.synapse_transaction_id}", 'png'], 'tmp',
                         :encoding => 'ascii-8bit')
    file.write(img)

    file
  end

  def group_total_fee_amount(fly_buy_order, seller_group)
    sum = 0 
    group_members = seller_group.group_sellers
    group_members.each do |group_member|
      per_unit_commission = group_member.additional_seller_fee.value.to_f
      total_fee = per_unit_commission * fly_buy_order.count
      sum = sum + total_fee
    end

    sum
  end

  def encode_attachment(file_tempfile:, file_type:)
    file_contents = IO.read(file_tempfile)
    encoded = Base64.encode64(file_contents)
    mime_padding = "data:#{file_type};base64,"
    mime_padding + encoded
  end

  def additional_seller_total_fee_amount(fly_buy_order, seller_group, add_seller)
    group_member = seller_group.group_sellers.find_by_user_id(add_seller.id)
    per_unit_fee_commission = group_member.additional_seller_fee.value
    fly_buy_order.count * per_unit_fee_commission
  end
end