class AddInspectionCompleteFieldToArmorOrder < ActiveRecord::Migration
  def change
    add_column :armor_orders, :inspection_complete, :boolean, default: false
  end
end
