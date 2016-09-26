class AddSynapseEscrowNodeIdToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :synapse_escrow_node_id, :string
  end
end
