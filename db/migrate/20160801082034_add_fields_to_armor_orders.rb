class AddFieldsToArmorOrders < ActiveRecord::Migration
  def change
    add_column :armor_orders, :inspection_date_by_seller, :datetime
    add_column :armor_orders, :inspection_date_by_buyer, :datetime
  end
end
