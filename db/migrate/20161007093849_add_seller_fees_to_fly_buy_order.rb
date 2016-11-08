class AddSellerFeesToFlyBuyOrder < ActiveRecord::Migration
  def change
  	add_column :fly_buy_orders, :seller_fees_percent, :float
  	add_column :fly_buy_orders, :seller_fees_amount, :float
  end
end
