module FlyAndBuy

  class AddCompanyDocumentJob < ActiveJob::Base

    queue_as :add_company_document

    def perform(user, fly_buy_profile, address_id)
      Services::FlyAndBuy::CompanyDocument.new(user, fly_buy_profile, address_id).submit
    end
  end
end
