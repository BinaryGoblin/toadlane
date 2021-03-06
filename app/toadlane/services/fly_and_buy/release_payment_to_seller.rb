module Services
  module FlyAndBuy

    class ReleasePaymentToSeller < Base
      attr_reader :user, :synapse_pay

      def initialize(user, fly_buy_order)
        @user = user
        fly_buy_profile = fly_buy_order.seller.fly_buy_profile
        @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: fly_buy_profile.synapse_ip_address, dynamic_fingerprint: fly_buy_profile.is_old_profile?)

        super(fly_buy_order, fly_buy_profile)
      end

      def process
        synapse_user = synapse_pay.user(user_id: SynapsePay::USER_ID)
        node = synapse_user.find_node(id: SynapsePay::ESCROW_NODE_ID)
        node.create_transaction(transaction_settings)
        update_fly_buy_order(status: :processing_fund_release)
      rescue SynapsePayRest::Error => e
        update_fly_buy_order(error_details: e.response['error'])
      end

      private

      def transaction_settings
        {
          to_type:      seller_account_type(fly_buy_profile),
          to_id:        fly_buy_profile.synapse_node_id,
          amount:       fly_buy_order.amount_pay_to_seller,
          currency:     SynapsePay::CURRENCY,
          ip:           user.fly_buy_profile.synapse_ip_address,
          process_in:   0,
          note:         'Released Payment',
          attachments:  [encode_file(file: convert_invoice_to_image(fly_buy_order, user), type: 'image/png')],
          supp_id:      "FlyBuyOrder:#{fly_buy_order.id}",
          fee_amount:   fly_buy_order.toadlane_earning,
          fee_note:     'Seller Fee',
          fee_to_id:    SynapsePay::ESCROW_FEE_HOLDER_NODE_ID
        }
      end
    end
  end
end
