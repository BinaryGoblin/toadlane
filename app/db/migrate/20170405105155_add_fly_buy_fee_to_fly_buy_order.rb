class AddFlyBuyFeeToFlyBuyOrder < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :fly_buy_fee, :float
  end
end
