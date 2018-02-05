class AddFieldsToArmorProfile < ActiveRecord::Migration
  def change
    add_column :armor_profiles, :confirmed_email, :boolean
    add_column :armor_profiles, :agreed_terms, :boolean
  end
end
