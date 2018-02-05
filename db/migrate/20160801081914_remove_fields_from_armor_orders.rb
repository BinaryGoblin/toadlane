class RemoveFieldsFromArmorOrders < ActiveRecord::Migration
  def change
    remove_column :armor_orders, :inspection_date
  end
end
