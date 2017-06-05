module Importers
  class Product < ActiveJob::Base

    queue_as :bulk_product_upload

    def perform(folder, current_user)
      begin
        Services::Importers::Product.import(folder, current_user)
        folder.update_attribute(:import_status, 'completed')
      rescue => e
        folder.update_attribute(:error_message, "Error: #{e.message}")
      end
    end
  end
end