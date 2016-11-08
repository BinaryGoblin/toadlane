class CreateUserForFlyBuyJob < ActiveJob::Base
  queue_as :default

  def perform(current_user_id, fly_buy_profile_id)
  	signed_in_user = User.find_by_id(current_user_id)
  	fly_buy_profile = FlyBuyProfile.find_by_id(fly_buy_profile_id)
    FlyAndBuy::UserOperations.new(signed_in_user, fly_buy_profile).create_user
  end
end
