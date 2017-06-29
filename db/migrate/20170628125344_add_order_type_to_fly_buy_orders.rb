class AddOrderTypeToFlyBuyOrders < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :order_type, :string
  end
end
