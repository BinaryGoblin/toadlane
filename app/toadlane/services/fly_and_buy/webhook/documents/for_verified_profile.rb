module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class ForVerifiedProfile < Base

          def initialize(fly_buy_profile)
            super(fly_buy_profile)
          end

          def process
            already_verified = fly_buy_profile.permission_scope_verified?

            update_fly_buy_profile(
              permission_scope_verified: true,
              kba_questions: {},
              completed: fly_buy_profile.bank_details_verified?
            )

            if fly_buy_profile.bank_details_verified?
              update_fly_buy_profile(error_details: {})

              notify_the_user(method_name: :send_account_verified_notification_to_user) unless already_verified
            end
          end
        end
      end
    end
  end
end
