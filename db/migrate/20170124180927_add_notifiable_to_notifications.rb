class AddNotifiableToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notifiable_id, :integer
    add_column :notifications, :notifiable_type, :text
  end
end
