class CreateTransactionForFlyBuyJobJob < ActiveJob::Base
  queue_as :default

  def perform(signed_in_user_id, fly_buy_profile_id, fly_buy_order_id)
    signed_in_user = User.find_by_id(signed_in_user_id)
    fly_buy_profile = FlyBuyProfile.find_by_id(fly_buy_profile_id)
    fly_buy_order = FlyBuyOrder.find_by_id(fly_buy_order_id)
    FlyAndBuy::CreateTransaction.new(signed_in_user, fly_buy_profile, fly_buy_order).process
  end
end
