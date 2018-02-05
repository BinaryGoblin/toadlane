class AddSynapseDocumentIdToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :synapse_document_id, :string
  end
end
