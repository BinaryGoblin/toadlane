class AddFieldPaymentReleasedToGroupToFlyBuyOrders < ActiveRecord::Migration
  def change
  	add_column :fly_buy_orders, :payment_released_to_group, :boolean, default: false
  end
end
