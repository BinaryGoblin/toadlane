class AddBrandColumnsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :brand, :string
    add_column :products, :model, :string
    add_column :products, :condition, :string
  end
end
