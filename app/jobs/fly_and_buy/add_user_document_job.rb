module FlyAndBuy

  class AddUserDocumentJob < ActiveJob::Base

    queue_as :add_user_document

    def perform(user, fly_buy_profile, address_id)
      Services::FlyAndBuy::UserDocument.new(user, fly_buy_profile, address_id).submit
    end
  end
end
