class AddShippingCostToStripeOrders < ActiveRecord::Migration
  def change
    add_column :stripe_orders, :shipping_cost,  :float
  end
end
