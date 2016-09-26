class AddSynapseEscrowNodeIdAndTransactionIdToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :synapse_escrow_node_id, :string
    add_column :fly_buy_profiles, :synapse_transaction_id, :string
  end
end
