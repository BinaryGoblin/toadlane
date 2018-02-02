class AddAttachementToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_attachment :fly_buy_profiles, :eic_attachment
  end
end
