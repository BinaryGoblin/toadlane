class AddPromiseOrderIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :promise_order_id, :integer
  end
end
