class CreateRefundRequests < ActiveRecord::Migration
  def change
    create_table :refund_requests do |t|
      t.integer :green_order_id
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
