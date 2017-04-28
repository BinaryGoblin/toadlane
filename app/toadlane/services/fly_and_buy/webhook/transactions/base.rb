module Services
  module FlyAndBuy
    module Webhook
      module Transactions

        class Base

          attr_reader :fly_buy_order

          def initialize(fly_buy_order)
            @fly_buy_order = fly_buy_order
          end

          protected

          def update_fly_buy_order(**options)
            fly_buy_order.update_attributes(options)
          end

          def notify_the_user(method_name:, extra_arg: nil)
            if extra_arg.present?
              UserMailer.send(method_name, fly_buy_order, extra_arg)
            else
              UserMailer.send(method_name, fly_buy_order)
            end.deliver_later
          end
        end
      end
    end
  end
end
