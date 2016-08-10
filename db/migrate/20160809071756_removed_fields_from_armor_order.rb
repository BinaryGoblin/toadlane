class RemovedFieldsFromArmorOrder < ActiveRecord::Migration
  def change
    remove_column :armor_orders, :inspection_date_approved_by_seller, :boolean
    remove_column :armor_orders, :inspection_date_approved_by_buyer, :boolean
    remove_column :armor_orders, :inspection_date_by_seller, :datetime
    remove_column :armor_orders, :inspection_date_by_buyer, :datetime
  end
end
