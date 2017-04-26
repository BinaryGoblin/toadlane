module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class Base

          attr_reader :fly_buy_profile

          def initialize(fly_buy_profile)
            @fly_buy_profile = fly_buy_profile
          end

          protected

          def update_fly_buy_profile(**options)
            fly_buy_profile.update_attributes(options)
          end

          def notify_the_user(method_name:)
            UserMailer.send(:method_name, fly_buy_profile).deliver_later
          end
        end
      end
    end
  end
end
