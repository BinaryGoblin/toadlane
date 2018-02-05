class AddDeletedToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :deleted, :boolean, default: false
  end
end
