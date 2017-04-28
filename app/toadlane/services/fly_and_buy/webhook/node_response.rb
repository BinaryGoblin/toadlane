module Services
  module FlyAndBuy
    module Webhook

      class NodeResponse

        attr_reader :fly_buy_profile, :options

        def initialize(options={})
          @options = options
          @fly_buy_profile = FlyBuyProfile.where(synapse_user_id: synapse_user_id).first
        end

        def handle
          already_verified = fly_buy_profile.bank_details_verified?

          if verified_for_transaction?
            update_fly_buy_profile(
              bank_details_verified: true,
              completed: fly_buy_profile.permission_scope_verified?
            )

            if fly_buy_profile.permission_scope_verified?
              update_fly_buy_profile(error_details: {})
              UserMailer.send_account_verified_notification_to_user(fly_buy_profile).deliver_later unless already_verified
            end
          else
            update_fly_buy_profile(
              bank_details_verified: false,
              error_details: error_details,
              completed: false
            )
          end
        end

        private

        def verified_for_transaction?
          allowed? && is_active?
        end

        def allowed?
          options['allowed'] == 'CREDIT-AND-DEBIT'
        end

        def is_active?
          options['is_active']
        end

        def update_fly_buy_profile(**options)
          fly_buy_profile.update_attributes(options)
        end

        def error_details
          return { "en": "Bank account deleted." } unless is_active?
          return { "en": "Bank account not allowed for transaction." } unless allowed?
        end

        def synapse_user_id
          options['user_id']
        end
      end
    end
  end
end
