module Services
  module FlyAndBuy

    class ReleasePaymentToAdditionalSellers < Base
      attr_reader :user, :fly_buy_profile, :fly_buy_order, :synapse_pay

      def initialize(user, fly_buy_profile, fly_buy_order)
        @user = user
        @fly_buy_profile = fly_buy_profile
        @fly_buy_order = fly_buy_order
        @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: fly_buy_profile.synapse_ip_address)
      end

      def process
        synapse_user = synapse_pay.user(user_id: SynapsePay::USER_ID)
        node = synapse_user.find_node(id: SynapsePay::ESCROW_NODE_ID)

        additional_sellers = fly_buy_order.additional_seller_fee_transactions.unpaid

        additional_sellers.each do |additional_seller|
          node.create_transaction(transaction_settings(additional_seller)) unless additional_seller.fee.zero?
        end
      end

      private

      def transaction_settings(additional_seller)
        file = convert_invoice_to_image(fly_buy_order, user)
        additional_seller_profile = additional_seller.user.fly_buy_profile

        {
          to_type:      seller_account_type(additional_seller_profile),
          to_id:        additional_seller_profile.synapse_node_id,
          amount:       additional_seller.fee,
          currency:     SynapsePay::CURRENCY,
          ip:           fly_buy_profile.synapse_ip_address,
          process_in:   0,
          note:         'Released Payment To Additional Seller',
          attachments:  [encode_file(file: file, type: 'image/png')],
          supp_id:      "FlyBuyOrder::AdditionalSellerFee-#{additional_seller.id}"
        }
      end
    end
  end
end
