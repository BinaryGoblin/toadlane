class AddFieldsToArmorOrder < ActiveRecord::Migration
  def change
    add_column :armor_orders, :fee, :float
    add_column :armor_orders, :rebate, :float
    add_column :armor_orders, :shipping_cost, :float
  end
end
