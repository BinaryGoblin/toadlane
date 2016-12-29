class ReleasePaymentToAdditionalSellersJob < ActiveJob::Base
  queue_as :default

  def perform(initial_seller_id, initial_seller_fly_buy_profile_id, fly_buy_order_id)
  	initial_seller = User.find_by_id(initial_seller_id)
  	initial_seller_fly_buy_profile = FlyBuyProfile.find_by_id(initial_seller_fly_buy_profile_id)
  	fly_buy_order = FlyBuyOrder.find_by_id(fly_buy_order_id)
 
  	FlyAndBuy::ReleasePaymentToAdditionalSellers.new(initial_seller, initial_seller_fly_buy_profile, fly_buy_order).process
  end
end
