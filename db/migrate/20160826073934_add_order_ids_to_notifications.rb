class AddOrderIdsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :amg_order_id, :integer
    add_column :notifications, :emb_order_id, :integer
    add_column :notifications, :stripe_order_id, :integer
    add_column :notifications, :green_order_id, :integer
  end
end
