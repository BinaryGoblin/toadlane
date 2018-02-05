class AddOutsideTheUsToFlyBuyProfiles < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :outside_the_us, :boolean, default: false
  end
end
