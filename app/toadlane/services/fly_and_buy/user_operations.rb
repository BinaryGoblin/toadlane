module Services
  module FlyAndBuy

    class UserOperations < Base
      attr_reader :user, :synapse_pay
      attr_accessor :fly_buy_profile

      def initialize(user, fly_buy_profile)
        @user = user
        @fly_buy_profile = fly_buy_profile
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)
      end

      def create_user
        synapse_user = synapse_pay.create_user(id: user.id, email: user.email, name: user.name, phone: user.phone)

        update_fly_buy_profile(synapse_user_id: synapse_user.id)
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: e.response['error'])
      end

      private

      def update_fly_buy_profile(**options)
        fly_buy_profile.update_attributes(options)
      end
    end
  end
end
