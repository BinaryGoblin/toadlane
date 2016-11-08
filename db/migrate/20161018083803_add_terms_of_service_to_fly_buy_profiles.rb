class AddTermsOfServiceToFlyBuyProfiles < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :terms_of_service, :boolean, default: false
  end
end
