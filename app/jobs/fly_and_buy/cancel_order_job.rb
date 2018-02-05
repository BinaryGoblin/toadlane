module FlyAndBuy

  class CancelOrderJob < ActiveJob::Base

    queue_as :cancel_order

    def perform(user, fly_buy_order)
      Services::FlyAndBuy::CancelTransaction.new(user, fly_buy_order).process
    end
  end
end
