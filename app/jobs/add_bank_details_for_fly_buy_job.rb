class AddBankDetailsForFlyBuyJob < ActiveJob::Base
  queue_as :default

  def perform(current_user, fly_buy_profile, fly_buy_params)
  	fly_buy_params = fly_buy_params.with_indifferent_access
    FlyAndBuy::AddingBankDetails.new(current_user, fly_buy_profile, fly_buy_params).add_details
  end
end
