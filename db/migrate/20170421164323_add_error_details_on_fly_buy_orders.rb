class AddErrorDetailsOnFlyBuyOrders < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :error_details, :json, default: {}
  end
end
