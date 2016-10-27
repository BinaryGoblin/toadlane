class CreateTransactionForFlyBuyJobJob < ActiveJob::Base
  queue_as :default

  def perform(fly_buy_profile_id, fly_buy_order_id)
  	fly_buy_profile = FlyBuyProfile.find_by_id(fly_buy_profile_id)
  	fly_buy_order = FlyBuyOrder.find_by_id(fly_buy_order_id)
  	FlyAndBuy::CreateTransaction.new(fly_buy_profile, fly_buy_order).process
  end
end
