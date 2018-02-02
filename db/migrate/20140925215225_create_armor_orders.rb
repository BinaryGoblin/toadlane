class CreateArmorOrders < ActiveRecord::Migration
  def change
    create_table :armor_orders do |t|
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :account_id
      t.integer :product_id
      t.integer :order_id
      t.integer :status		# completed, rejected, in progress
      t.float :unit_price
      t.integer :count		# as 'quantity' in psd
      t.float :amount		# as 'order total' in psd
      t.string :summary, limit: 100
      t.text :description, limit: 10000
      t.integer :invoice_num
      t.integer :purchase_order_num
      t.datetime :status_change
      t.string :uri
      t.boolean :deleted, default: false
      t.timestamps
    end
  end
end
