desc 'After order is placed and item created check the order status'
task :update_order_status => :environment do
  promise_orders = PromiseOrder.with_promise_item_id.payment_pending
  if promise_orders.any?
    promise_pay_instance = PromisePayService.new
    client = promise_pay_instance.client

    promise_orders.each do |promise_order|
      item = client.items.find(promise_order.promise_item_id)
      promise_order.update(status: item.state)
    end
  end
end
