class AddShippingCostToFlybuyOrders < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :shipping_cost,         :float
    add_column :fly_buy_orders, :shipping_estimate_id,  :integer
  end
end
