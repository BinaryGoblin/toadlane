class AddIpAddressToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :synapse_ip_address, :string
  end
end
