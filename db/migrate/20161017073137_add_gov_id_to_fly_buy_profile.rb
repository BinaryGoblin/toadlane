class AddGovIdToFlyBuyProfile < ActiveRecord::Migration
  def change
  	add_attachment :fly_buy_profiles, :gov_id
  end
end
