class AddFieldsToFlyBuyProfile < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :name_on_account, :string
  	add_column :fly_buy_profiles, :ssn_number, :integer
  	add_column :fly_buy_profiles, :date_of_company, :datetime
  	add_column :fly_buy_profiles, :dob, :datetime
  	add_column :fly_buy_profiles, :entity_type, :string
  	add_column :fly_buy_profiles, :entity_scope, :string
  	add_column :fly_buy_profiles, :o_entity_scope, :string
  	add_column :fly_buy_profiles, :o_entity_type, :string
  	add_column :fly_buy_profiles, :company_email, :string
  	add_column :fly_buy_profiles, :tin_number, :integer
  	add_column :fly_buy_profiles, :company_phone, :string
  	add_column :fly_buy_profiles, :completed, :boolean, default: false
  end
end
