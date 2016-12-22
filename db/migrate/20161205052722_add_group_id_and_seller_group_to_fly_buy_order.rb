class AddGroupIdAndSellerGroupToFlyBuyOrder < ActiveRecord::Migration
  def change
  	add_column :fly_buy_orders, :group_seller_id, :integer
  	add_column :fly_buy_orders, :group_seller, :boolean, default: false
  end
end
