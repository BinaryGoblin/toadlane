class ChangeOrderIdToBigInt < ActiveRecord::Migration
  def change
    change_column :armor_orders, :order_id, :bigint
  end
end
