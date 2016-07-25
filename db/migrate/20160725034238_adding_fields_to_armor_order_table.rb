class AddingFieldsToArmorOrderTable < ActiveRecord::Migration
  def change
    add_column :armor_orders, :inspection_date, :datetime
    add_column :armor_orders, :inspection_date_approved_by_seller, :boolean, default: false
    add_column :armor_orders, :inspection_date_approved_by_buyer, :boolean, default: false
  end
end
