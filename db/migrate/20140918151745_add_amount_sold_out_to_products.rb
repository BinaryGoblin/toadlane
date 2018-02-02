class AddAmountSoldOutToProducts < ActiveRecord::Migration
  def change
    add_column :products, :amount, :integer
    add_column :products, :sold_out, :integer
    add_column :products, :dimension_width, :string
    add_column :products, :dimension_height, :string
    add_column :products, :dimension_depth, :string
    add_column :products, :dimension_weight, :string
  end
end
