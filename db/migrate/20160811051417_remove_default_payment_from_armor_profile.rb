class RemoveDefaultPaymentFromArmorProfile < ActiveRecord::Migration
  def change
    remove_column :armor_profiles, :default_payment, :string
  end
end
