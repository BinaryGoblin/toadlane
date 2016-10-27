class FlyAndBuy::CreateTransaction

	attr_accessor  :client, :fly_buy_profile, :client_user, :fly_buy_order

	def initialize(fly_buy_profile, fly_buy_order)
		@fly_buy_profile = fly_buy_profile
		@fly_buy_order = fly_buy_order
		@client = FlyBuyService.get_client
		FlyBuyService.create_subscription
	end

	def process
		create_transaction_process
	end


	private

	def create_transaction_process
		get_user_and_instantiate_user

		transaction_create_response = create_transcation

		if create_transaction_response["recent_status"]["note"] == "Transaction created"
			update_fly_buy_order(create_transaction_response)

			update_product_count

			send_email_notification
		end
	end

	def send_email_notification
    UserMailer.sales_order_notification_to_seller(fly_buy_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(fly_buy_order).deliver_later
  end

	def update_product_count
		product = fly_buy_order.product
		product.sold_out += fly_buy_order.count
    product.save
  end

	def update_fly_buy_order(create_transaction_response)
		seller_fee_percent, seller_fee_amount = get_seller_fees

		fly_buy_order.update_attributes({
      synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
      synapse_transaction_id: create_transaction_response["_id"],
      status: 'pending_confirmation',
      seller_fees_amount: seller_fee_amount,
      seller_fees_percent: seller_fee_percent,
    })
	end

	def get_user_and_instantiate_user
    user_response = client.users.get(user_id: fly_buy_profile.synapse_user_id)

    client_user = FlyBuyService.get_user(
                      oauth_key: nil,
                      fingerprint: fly_buy_profile.encrypted_fingerprint,
                      ip_address: fly_buy_profile.synapse_ip_address,
                      user_id: fly_buy_profile.synapse_user_id
                  )

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => fly_buy_profile.encrypted_fingerprint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    @client_user =  FlyBuyService.get_user(
                      oauth_key: oauth_response["oauth_key"],
                      fingerprint: fly_buy_profile.encrypted_fingerprint,
                      ip_address: fly_buy_profile.synapse_ip_address,
                      user_id: fly_buy_profile.synapse_user_id
                  )
  end

  def create_transcation
  	if Rails.env.development?
      webhook_url = Rails.application.secrets['SYNAPSEPAY_WEBHOOK_URL']
    else
      webhook_url = ENV['SYNAPSEPAY_WEBHOOK_URL']
    end

    file = convert_invoice_to_image

  	trans_payload = {
      "to" => {
        "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:synapse_us],
        "id" => FlyBuyProfile::EscrowNodeID
      },
      "amount" => {
        "amount" => fly_buy_order.total,
        "currency" => FlyAndBuy::AddingBankDetails::SynapsePayCurrency
      },
      "extra" => {
        "note" => "Transaction Created",
        "webhook" => webhook_url,
        "process_on" => 0,
        "ip" => fly_buy_profile.synapse_ip_address,
        "other" => {
          "attachments" => [
            encode_attachment(file_tempfile: file.path, file_type: 'image/png')
          ]
        }
      },
      # "fees" => [{
      #   "fee" => 1.00,
      #   "note" => "Facilitator Fee",
      #   "to" => {
      #     "id" => "55d9287486c27365fe3776fb"
      #   }
      # }]
    }

    client_user.trans.create(node_id: fly_buy_profile.synapse_node_id, payload: trans_payload)
  end

	def convert_invoice_to_image
		ac = ActionController::Base.new()
    html = ac.render_to_string(
        {
            layout: 'layouts/print.html.slim',
            file: Rails.root + '/app/views/shared/_invoice.html.slim',
            locals: {order: fly_buy_order}
        })
    kit = IMGKit.new(html)
    img = kit.to_png
    file  = Tempfile.new(["template_#{fly_buy_order.synapse_transaction_id}", 'png'], 'tmp',
                         :encoding => 'ascii-8bit')
    file.write(img)

    file
  end

  def get_seller_fees
    order_amount = fly_buy_order.total

    if order_amount < 1000000
      fee_percent = 1
      amount = order_amount * 1/100
    elsif order_amount >= 1000000
      fee_percent = 0.35
      amount = order_amount * 0.35/100
    end

    [fee_percent, amount]
  end

  def encode_attachment(file_tempfile:, file_type:)
    file_contents = IO.read(file_tempfile)
    encoded = Base64.encode64(file_contents)
    mime_padding = "data:#{file_type};base64,"
    mime_padding + encoded
  end
end