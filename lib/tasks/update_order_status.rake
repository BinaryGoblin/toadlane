# desc 'After order is placed and item created check the order status'
# task :update_order_status => :environment do
#   promise_pay_instance = PromisePayService.new
#   client = promise_pay_instance.client
#   promise_orders = PromiseOrder.with_promise_item_id.payment_pending
#   if promise_orders.any?

#     promise_orders.each do |promise_order|
#       item = client.items.find(promise_order.promise_item_id)
#       promise_order.update(status: item.state)
#       if item.state == "payment_deposited"
#         promise_order.update(funds_in_escrow: true)
#         UserMailer.send_payment_released_notification_to_seller(promise_order).deliver_later
#       end
#     end
#   end

#   promise_orders = PromiseOrder.with_promise_item_id.completed
#   if promise_orders.any?
#     promise_orders.each do |promise_order|
#       item = client.items.find(promise_order.promise_item_id)
#       UserMailer.send_payment_released_notification_to_seller(promise_order).deliver_later
#     end
#   end
# end
