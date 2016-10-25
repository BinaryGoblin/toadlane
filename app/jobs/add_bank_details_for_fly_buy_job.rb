class AddBankDetailsForFlyBuyJob < ActiveJob::Base
  queue_as :default

  def perform(current_user_id, fly_buy_profile_id, fly_buy_params)
  	fly_buy_params = fly_buy_params.with_indifferent_access
  	signed_in_user = User.find_by_id(current_user_id)
  	fly_buy_profile = FlyBuyProfile.find_by_id(fly_buy_profile_id)
    FlyAndBuy::AddingBankDetails.new(signed_in_user, fly_buy_profile, fly_buy_params).add_details
  end
end
