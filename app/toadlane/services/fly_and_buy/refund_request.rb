module Services
  module FlyAndBuy

    class RefundRequest < Base
      attr_reader :user, :synapse_pay

      def initialize(user, fly_buy_order)
        @user = user
        @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: user.fly_buy_profile.synapse_ip_address)

        super(fly_buy_order, fly_buy_order.buyer.fly_buy_profile)
      end

      def process
        synapse_user = synapse_pay.user(user_id: SynapsePay::USER_ID)
        node = synapse_user.find_node(id: SynapsePay::ESCROW_NODE_ID)
        transaction = node.create_transaction(transaction_settings)

        if transaction.recent_status['status'] == 'CREATED'
          update_fly_buy_order(status: :cancelled)

          send_email_notification
        end
      end

      private

      def transaction_settings
        file = convert_invoice_to_image(fly_buy_order, user)

        {
          to_type:      seller_account_type(fly_buy_profile),
          to_id:        fly_buy_profile.synapse_node_id,
          amount:       fly_buy_order.refund_amount,
          currency:     SynapsePay::CURRENCY,
          ip:           fly_buy_profile.synapse_ip_address,
          process_in:   0,
          note:         'Transaction Refunded',
          supp_id:      "FlyBuyOrder:#{fly_buy_order.id}",
          attachments:  [encode_file(file: file, type: 'image/png')]
        }
      end

      def send_email_notification
        notify_order_details_to_user(method_name: :notify_buyer_for_placed_cancle_fly_buy_order)
        
        additional_sellers_emails = []
        additional_sellers_emails = fly_buy_order.seller_group.group_sellers.map { |group_seller| group_seller.user.email } if fly_buy_order.seller_group.present?

        notify_order_details_to_user(method_name: :notify_seller_and_additional_sellers_for_buyer_placed_cancle_fly_buy_order, extra_arg: additional_sellers_emails)
      end
    end
  end
end
