class AddDefaultPaymentToArmorProfile < ActiveRecord::Migration
  def change
    add_column :armor_profiles, :default_payment, :boolean, default: false
  end
end
