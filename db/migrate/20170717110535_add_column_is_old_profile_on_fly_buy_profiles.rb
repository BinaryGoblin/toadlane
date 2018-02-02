class AddColumnIsOldProfileOnFlyBuyProfiles < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :is_old_profile, :boolean, default: false

    FlyBuyProfile.reset_column_information
    FlyBuyProfile.find_each do |fly_buy_profile|
      fly_buy_profile.update_attribute(:is_old_profile, true)
    end
  end
end
