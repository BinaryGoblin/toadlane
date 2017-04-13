module FlyAndBuy

  class AddBankDetailsJob < ActiveJob::Base

    queue_as :add_bank_details

    def perform(user, fly_buy_profile, fly_buy_params)
      Services::FlyAndBuy::BankDetails.new(user, fly_buy_profile, fly_buy_params).add
    end
  end
end
