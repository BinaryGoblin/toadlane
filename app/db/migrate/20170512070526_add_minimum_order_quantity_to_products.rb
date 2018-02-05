class AddMinimumOrderQuantityToProducts < ActiveRecord::Migration
  def change
    add_column :products, :minimum_order_quantity, :integer, default: 1, null: false
  end
end
