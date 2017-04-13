module FlyAndBuy

  class ReleasePaymentToAdditionalSellers

    attr_accessor :user, :fly_buy_profile, :fly_buy_order, :seller_group

    def initialize(user, fly_buy_profile, fly_buy_order)
      @user = user
      @fly_buy_profile = fly_buy_profile
      @fly_buy_order = fly_buy_order
      @seller_group = @fly_buy_order.seller_group

      @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)
    end

    def process
      synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
      node = synapse_user.find_node(id: fly_buy_profile.synapse_node_id)
      transaction = node.create_transaction(transaction_settings)

      FlyAndBuy::CreateTransactionForAdditionalSeller.new(user, fly_buy_profile, fly_buy_order).process if transaction.recent_status['status'] == 'CREATED'
    end

    private

    def transaction_settings
      file = convert_invoice_to_image(fly_buy_order, user)

      {
        to_type:  'SYNAPSE-US',
        to_id:    SynapsePay::ESCROW_NODE_ID,
        amount:   total_fee_for_group_seller,
        currency: SynapsePay::CURRENCY,
        ip:       fly_buy_profile.synapse_ip_address,
        process_in: 0,
        note: 'Transaction Created for paying to group members',
        attachments: [encode_file(file: file, type: 'image/png')]
      }
    end

    def total_fee_for_group_seller
      sum = 0 
      group_members = seller_group.group_sellers
      group_members.each do |group_member|
        total_fee = calulate_total_fee(fly_buy_order, group_member.additional_seller_fee.value)
        sum += total_fee
      end

      sum
    end
  end
end
