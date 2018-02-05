class AddSubmitedOnFlyBuyProfiles < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :submited, :boolean, default: false
  end
end
