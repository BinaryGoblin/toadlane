module FlyAndBuy

  class PlaceOrderJob < ActiveJob::Base

    queue_as :place_order

    def perform(user, fly_buy_order)
      Services::FlyAndBuy::CreateTransaction.new(user, user.fly_buy_profile, fly_buy_order).process
    end
  end
end
