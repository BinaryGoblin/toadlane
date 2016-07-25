class AddingFieldsToArmorOrderTable < ActiveRecord::Migration
  def change
    add_column :armor_orders, :inspection_date, :datetime
    add_column :armor_orders, :inspection_date_approved, :boolean, default: false
  end
end
