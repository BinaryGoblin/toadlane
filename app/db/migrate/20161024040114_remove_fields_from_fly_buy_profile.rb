class RemoveFieldsFromFlyBuyProfile < ActiveRecord::Migration
  def change
  	remove_column :fly_buy_profiles, :o_entity_scope
  	remove_column :fly_buy_profiles, :o_entity_type
  	remove_column :fly_buy_profiles, :company_phone
  end
end
