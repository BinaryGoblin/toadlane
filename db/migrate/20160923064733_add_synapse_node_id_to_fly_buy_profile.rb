class AddSynapseNodeIdToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :synapse_node_id, :string
  end
end
