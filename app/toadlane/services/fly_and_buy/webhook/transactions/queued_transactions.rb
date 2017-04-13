module Services
  module FlyAndBuy
    module Webhook
      module Transactions

        class QueuedTransactions < Base

          def initialize(fly_buy_order)
            super(fly_buy_order)
          end

          def process
            update_fly_buy_order(status: :queued)

            notify_the_user(method_name: :send_order_queued_notification_to_seller)
            notify_the_user(method_name: :send_order_queued_notification_to_buyer)
          end
        end

      end
    end
  end
end
