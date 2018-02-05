class AddInspectionDateToProducts < ActiveRecord::Migration
  def change
    add_column :products, :inspection_date, :datetime
  end
end
