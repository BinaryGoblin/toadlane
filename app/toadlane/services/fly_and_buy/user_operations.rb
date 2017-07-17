module Services
  module FlyAndBuy

    class UserOperations < Base

      attr_reader :user, :synapse_pay

      def initialize(user, fly_buy_profile)
        @user = user
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address, dynamic_fingerprint: fly_buy_profile.is_old_profile?)

        super(nil, fly_buy_profile)
      end

      def create_user
        synapse_user = synapse_pay.create_user(id: user.id, email: user.email, name: user.name, phone: user.phone)

        update_fly_buy_profile(synapse_user_id: synapse_user.id)
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: e.response['error'])
      end
    end
  end
end
