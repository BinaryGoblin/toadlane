class AddBusinessDocumentsToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_attachment :fly_buy_profiles, :business_documents
  end
end
