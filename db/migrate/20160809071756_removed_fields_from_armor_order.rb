class RemovedFieldsFromArmorOrder < ActiveRecord::Migration
  def change
    remove_column :armor_orders, :inspection_date_approved_by_seller
    remove_column :armor_orders, :inspection_date_approved_by_buyer
    remove_column :armor_orders, :inspection_date_by_seller
    remove_column :armor_orders, :inspection_date_by_buyer
  end
end
