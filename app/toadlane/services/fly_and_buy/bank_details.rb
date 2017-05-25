module Services
  module FlyAndBuy

    class BankDetails < Base
      attr_reader :user, :options, :synapse_pay

      def initialize(user, fly_buy_profile, options = {})
        @user = user
        @options = options
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)

        super(nil, fly_buy_profile)
      end

      def add
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        create_bank_account(synapse_user)
      rescue SynapsePayRest::Error => e
        UserMailer.send_routing_number_incorrect_notification(user).deliver_later if e.response['error']['en'].present? && e.response['error']['en'].include?('routing_num')
        update_fly_buy_profile(error_details: e.response['error'])
      end

      private

      def create_bank_account(synapse_user)
        account_info = {
          bank_name:        options[:bank_name],
          account_number:   options[:account_num],
          routing_number:   options[:routing_num],
          name_on_account:  options[:name_on_account],
          address:          options[:address]
        }
        bank_response = if fly_buy_profile.outside_the_us?
          account_info.merge!(swift: options[:swift]) if options[:swift].present?
          account_info.merge!(nickname: "#{user.name} (WIRE-INT)")

          synapse_user.create_wire_int_node(account_info)
        else
          account_info.merge!(nickname: "#{user.name} (WIRE-US)")

          synapse_user.create_wire_us_node(account_info)
        end

        update_fly_buy_profile(synapse_node_id: bank_response.id)
      end
    end
  end
end
