desc 'Delete all the invalid fly buy orders'
task delete_invalid_fly_buy_orders: :environment do
  fly_buy_orders = FlyBuyOrder.invalid

  fly_buy_orders.each do |fly_buy_order|
    fly_buy_order.rollback_product_count
    fly_buy_order.destroy
  end
end
