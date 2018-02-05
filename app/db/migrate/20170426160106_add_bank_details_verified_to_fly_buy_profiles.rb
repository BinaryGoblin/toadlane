class AddBankDetailsVerifiedToFlyBuyProfiles < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :bank_details_verified, :boolean, default: false
  end
end
