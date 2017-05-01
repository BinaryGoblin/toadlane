module Services
  module FlyAndBuy

    class CancelTransaction < Base
      attr_reader :user, :fly_buy_order, :synapse_pay

      def initialize(user, fly_buy_order)
        @user = user
        @fly_buy_order = fly_buy_order
        @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: user.fly_buy_profile.synapse_ip_address)
      end

      def process
        synapse_user = synapse_pay.user(user_id: SynapsePay::USER_ID)
        node = synapse_user.find_node(id: SynapsePay::ESCROW_NODE_ID)
        transaction = node.find_transaction(id: fly_buy_order.synapse_transaction_id)

        case transaction.recent_status
        when 'SETTELED'
          RefundRequest.new(user, fly_buy_order)
        else
          cancel_response = transaction.cancel
        end
      rescue SynapsePayRest::Error => e
        handle_synapse_pay_rest_error(node, e)
      end

      private

      def update_product_count
        product = fly_buy_order.product
        product.sold_out -= fly_buy_order.count
        product.save
      end

      def update_fly_buy_order(**options)
        fly_buy_order.update_attributes(options)
      end

      def handle_synapse_pay_rest_error(node, e)
        transaction = node.find_transaction(id: fly_buy_order.synapse_transaction_id)
        update_fly_buy_order(status: :pending_inspection, funds_in_escrow: true) if transaction.recent_status['status_id'].to_i == 4
        update_fly_buy_order(error_details: e.response['error'])
      end
    end
  end
end
