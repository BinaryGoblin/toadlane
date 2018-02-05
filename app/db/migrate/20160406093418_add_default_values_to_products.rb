class AddDefaultValuesToProducts < ActiveRecord::Migration
  def change
    change_column :products, :sold_out, :bigint, null: false, default: 0
  end
end
