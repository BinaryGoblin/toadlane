class CreatePromiseOrders < ActiveRecord::Migration
  def change
    create_table :promise_orders do |t|
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :product_id
      t.integer :status		# completed, rejected, in progress
      t.float :unit_price
      t.integer :count
      t.float :fee
      t.float :rebate
      t.float :rebate_price
      t.float :amount
      t.datetime :status_change
      t.boolean :deleted, default: false
      t.timestamps null: false
    end
  end
end
