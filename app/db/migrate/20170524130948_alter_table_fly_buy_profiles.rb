class AlterTableFlyBuyProfiles < ActiveRecord::Migration
  def change
    rename_column :fly_buy_profiles, :synapse_document_id, :synapse_user_doc_id
    add_column :fly_buy_profiles, :synapse_company_doc_id, :string
    add_column :fly_buy_profiles, :company_doc_verified, :boolean, default: false
    add_column :fly_buy_profiles, :user_doc_verified, :boolean, default: false
  end
end
