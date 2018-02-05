class AddSynapseEscrowNodeIdAndTransactionIdToFlyBuyOrder < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :synapse_escrow_node_id, :string
    add_column :fly_buy_orders, :synapse_transaction_id, :string
  end
end
