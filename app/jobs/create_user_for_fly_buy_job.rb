class CreateUserForFlyBuyJob < ActiveJob::Base
  queue_as :default

  def perform(current_user, fly_buy_profile)
    FlyAndBuy::UserOperations.new(current_user, fly_buy_profile).create_user
  end
end
