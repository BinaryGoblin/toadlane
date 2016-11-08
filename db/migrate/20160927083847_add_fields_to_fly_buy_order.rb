class AddFieldsToFlyBuyOrder < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :inspection_complete, :boolean, default: false
    add_column :fly_buy_orders, :payment_release, :boolean, default: false
    add_column :fly_buy_orders, :funds_in_escrow, :boolean, default: false
  end
end
