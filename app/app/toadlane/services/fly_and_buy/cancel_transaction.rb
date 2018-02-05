module Services
  module FlyAndBuy

    class CancelTransaction < Base
      attr_reader :user, :synapse_pay

      def initialize(user, fly_buy_order)
        @user = user
        @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: user.fly_buy_profile.synapse_ip_address, dynamic_fingerprint: user.fly_buy_profile.is_old_profile?)

        super(fly_buy_order, nil)
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

      def handle_synapse_pay_rest_error(node, e)
        status = (fly_buy_order.order_type == 'same_day') ? :placed : :pending_inspection
        transaction = node.find_transaction(id: fly_buy_order.synapse_transaction_id)
        update_fly_buy_order(status: status, funds_in_escrow: true) if transaction.recent_status['status_id'].to_i == 4
        update_fly_buy_order(error_details: e.response['error'])
      end
    end
  end
end
