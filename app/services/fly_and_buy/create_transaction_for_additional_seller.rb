module FlyAndBuy

  class CreateTransactionForAdditionalSeller < Base

    attr_accessor :user, :fly_buy_profile, :fly_buy_order, :group_sellers, :synapse_pay

    def initialize(user, fly_buy_profile, fly_buy_order)
      @user = user
      @fly_buy_profile = fly_buy_profile
      @fly_buy_order = fly_buy_order
      @group_sellers = fly_buy_order.seller_group.group_sellers

      @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: fly_buy_profile.synapse_ip_address)
    end

    def process
      synapse_user = synapse_pay.user(user_id: SynapsePay::USER_ID)
      node = synapse_user.find_node(id: SynapsePay::ESCROW_NODE_ID)
      additional_sellers = fly_buy_order.product.additional_sellers
      a = 0

      additional_sellers.each do |add_seller|
        transaction = node.create_transaction(transaction_settings(add_seller))

        a += 1 if transaction.recent_status['status'] == 'CREATED'
      end

      # if group_sellers.count == a
      #   fly_buy_order.update_attribute(:payment_released_to_group, true)
      # end
    end

    private

    def transaction_settings(add_seller)
      file = convert_invoice_to_image(fly_buy_order, user)
      add_seller_fly_buy_profile = add_seller.fly_buy_profile

      {
        to_type:      seller_account_type(add_seller_fly_buy_profile),
        to_id:        add_seller_fly_buy_profile.synapse_node_id,
        amount:       total_fee_for_additional_seller(add_seller),
        currency:     SynapsePay::CURRENCY,
        ip:           fly_buy_profile.synapse_ip_address,
        process_in:   0,
        note:         'Released Payment To Additional Seller',
        attachments:  [encode_file(file: file, type: 'image/png')],
        supp_id:      "FlyBuyOrder_#{fly_buy_order.id}"
      }
    end

    def total_fee_for_additional_seller(add_seller)
      group_member = group_sellers.find_by_user_id(add_seller.id)

      calulate_total_fee(fly_buy_order, group_member.additional_seller_fee.value)
    end
  end
end
