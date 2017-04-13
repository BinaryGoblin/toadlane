module FlyAndBuy

  class CreateUserJob < ActiveJob::Base

    queue_as :create_user

    def perform(user, fly_buy_profile)
      Services::FlyAndBuy::UserOperations.new(user, fly_buy_profile).create_user
    end
  end
end
