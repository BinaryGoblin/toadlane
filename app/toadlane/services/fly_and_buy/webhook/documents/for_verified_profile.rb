module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class ForVerifiedProfile < Base

          def initialize(fly_buy_profile)
            super(fly_buy_profile)
          end

          def process
            if !fly_buy_profile.permission_scope_verified? && fly_buy_profile.synapse_node_id.present?
              update_fly_buy_profile(
                permission_scope_verified: true,
                kba_questions: {},
                completed: true,
                error_details: {}
              )
              notify_the_user(method_name: :send_account_verified_notification_to_user)
            end
          end
        end

      end
    end
  end
end
