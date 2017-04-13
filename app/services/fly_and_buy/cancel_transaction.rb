module FlyAndBuy

  class CancelTransaction < Base

    attr_accessor :user, :fly_buy_order, :fly_buy_profile, :synapse_pay

    def initialize(user, fly_buy_order)
      @user = user
      @fly_buy_order = fly_buy_order
      @fly_buy_profile = fly_buy_order.buyer.fly_buy_profile

      @synapse_pay = SynapsePay.new(fingerprint: SynapsePay::FINGERPRINT, ip_address: user.fly_buy_profile.synapse_ip_address)
    end

    def process
      synapse_user = synapse_pay.user(user_id: SynapsePay::USER_ID)
      node = synapse_user.find_node(id: fly_buy_profile.synapse_node_id)
      transaction = node.find_transaction(id: fly_buy_order.synapse_transaction_id)
      cancel_response = transaction.cancel

      if cancel_response.recent_status['status'] == 'CANCELED'
        update_product_count
        update_fly_buy_order(status: :cancelled, error_details: {})
      end
    rescue SynapsePayRest::Error => e
      transaction = node.find_transaction(id: fly_buy_order.synapse_transaction_id)

      update_fly_buy_order(status: :pending_inspection, funds_in_escrow: true) if transaction.recent_status['status_id'].to_i == 4
      update_fly_buy_order(error_details: e.response['error'])
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
  end
end
