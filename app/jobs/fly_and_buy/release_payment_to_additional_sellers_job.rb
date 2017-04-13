module FlyAndBuy

  class ReleasePaymentToAdditionalSellersJob < ActiveJob::Base
    queue_as :release_payment_to_additional_sellers

    def perform(user, fly_buy_order)
      Services::FlyAndBuy::ReleasePaymentToAdditionalSellers.new(user, user.fly_buy_profile, fly_buy_order).process
    end
  end
end
