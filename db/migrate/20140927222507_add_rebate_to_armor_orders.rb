class AddRebateToArmorOrders < ActiveRecord::Migration
  def change
    add_column :armor_orders, :taxes_price, :integer, default: 0
    add_column :armor_orders, :rebate_price, :integer, default: 0
    add_column :armor_orders, :rebate_percent, :integer, default: 0
  end
end
