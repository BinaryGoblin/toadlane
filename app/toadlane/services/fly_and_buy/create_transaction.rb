module Services
  module FlyAndBuy

    class CreateTransaction < Base
      attr_reader :user, :synapse_pay

      def initialize(user, fly_buy_profile, fly_buy_order)
        @user = user
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)

        super(fly_buy_order, fly_buy_profile)
      end

      def process
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        node = synapse_user.find_node(id: fly_buy_profile.synapse_node_id)
        transaction = node.create_transaction(transaction_settings)

        if transaction.recent_status['status'] == 'CREATED'
          update_fly_buy_order(
            synapse_escrow_node_id: SynapsePay::ESCROW_NODE_ID,
            synapse_transaction_id: transaction.id,
            status: :pending_confirmation
          )

          update_product_count
          send_email_notification
        end
      end

      private

      def transaction_settings
        file = convert_invoice_to_image(fly_buy_order, user)

        {
          to_type:  'SYNAPSE-US',
          to_id:    SynapsePay::ESCROW_NODE_ID,
          amount:   fly_buy_order.total,
          currency: SynapsePay::CURRENCY,
          ip:       fly_buy_profile.synapse_ip_address,
          process_in: 0,
          note: 'Transaction Created',
          attachments: [encode_file(file: file, type: 'image/png')]
        }
      end

      def send_email_notification
        notify_order_details_to_user(method_name: :fly_buy_order_notification_to_buyer)
        notify_order_details_to_user(method_name: :sales_order_notification_to_seller)

        fly_buy_order.seller_group.group_sellers.each do |group_seller|
          notify_order_details_to_user(method_name: :sales_order_notification_to_additional_seller, extra_arg: group_seller)
        end if fly_buy_order.seller_group.present?
      end
    end
  end
end
