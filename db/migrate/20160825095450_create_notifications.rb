class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :armor_order_id
      t.string :title
      t.boolean :read, default: false
      t.timestamps null: false
    end
  end
end
