class AddDefaultPaymentToArmorProfile < ActiveRecord::Migration
  def change
    add_column :armor_orders, :default_payment, :boolean, default: false
  end
end
