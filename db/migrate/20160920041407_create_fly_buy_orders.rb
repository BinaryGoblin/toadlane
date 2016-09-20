class CreateFlyBuyOrders < ActiveRecord::Migration
  def change
    create_table :fly_buy_orders do |t|
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :product_id
      t.integer :status
      t.float :unit_price
      t.integer :count
      t.float :fee
      t.float :rebate
      t.float :rebate_price
      t.float :total
      t.datetime :status_change
      t.boolean :deleted, default: false

      t.timestamps null: false
    end
  end
end
