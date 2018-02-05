class AddColumnProfileTypeToFlyBuyProfiles < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :profile_type, :string
    add_column :fly_buy_profiles, :gender, :string
  end
end
