class RemoveInspectionDateFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :inspection_date
  end
end
