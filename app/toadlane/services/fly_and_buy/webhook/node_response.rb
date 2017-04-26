module Services
  module FlyAndBuy
    module Webhook

      class NodeResponse

        attr_reader :fly_buy_profile, :permission, :options

        def initialize(synapse_user_id, **options)
          @fly_buy_profile = FlyBuyProfile.where(synapse_user_id: synapse_user_id).first
          @options = options
        end

        def handle
          if verified_for_transaction?
            update_fly_buy_profile(
              bank_details_verified: true,
              completed: fly_buy_profile.permission_scope_verified?
            )

            if fly_buy_profile.permission_scope_verified?
              update_fly_buy_profile(error_details: {})
              UserMailer.send_account_verified_notification_to_user(fly_buy_profile).deliver_later
            end
          else
            fly_buy_profile.update_attributes(
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
      end
    end
  end
end
