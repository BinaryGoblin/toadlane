module Services
  module FlyAndBuy

    class CreateTransaction < Base

      attr_accessor :user, :fly_buy_profile, :fly_buy_order, :synapse_pay

      def initialize(user, fly_buy_profile, fly_buy_order)
        @user = user
        @fly_buy_profile = fly_buy_profile
        @fly_buy_order = fly_buy_order

        @synapse_pay = Services::SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)
      end

      def process
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        node = synapse_user.find_node(id: fly_buy_profile.synapse_node_id)
        transaction = node.create_transaction(transaction_settings)

        if transaction.recent_status['status'] == 'CREATED'
          update_fly_buy_order(
            synapse_escrow_node_id: Services::SynapsePay::ESCROW_NODE_ID,
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
          to_id:    Services::SynapsePay::ESCROW_NODE_ID,
          amount:   fly_buy_order.total,
          currency: Services::SynapsePay::CURRENCY,
          ip:       fly_buy_profile.synapse_ip_address,
          process_in: 0,
          note: 'Transaction Created',
          attachments: [encode_file(file: file, type: 'image/png')]
        }
      end

      def update_product_count
        product = fly_buy_order.product
        product.sold_out += fly_buy_order.count
        product.save
      end

      def send_email_notification
        UserMailer.fly_buy_order_notification_to_buyer(fly_buy_order).deliver_later
        UserMailer.sales_order_notification_to_seller(fly_buy_order).deliver_later
        fly_buy_order.seller_group.group_sellers.each do |group_seller|
          UserMailer.sales_order_notification_to_additional_seller(fly_buy_order, fly_buy_order.seller_group, group_seller).deliver_later
        end if fly_buy_order.seller_group.present?
      end

      def update_fly_buy_order(**options)
        fly_buy_order.update_attributes(options)
      end
    end
  end
end
