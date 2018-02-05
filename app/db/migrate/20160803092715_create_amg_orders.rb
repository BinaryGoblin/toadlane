class CreateAmgOrders < ActiveRecord::Migration
  def change
    create_table :amg_orders do |t|
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :product_id
      t.integer :status
      t.float :unit_price
      t.integer :count
      t.float :fee
      t.float :rebate
      t.float :total
      t.string :summary
      t.text :description
      t.string :tracking_number
      t.boolean :deleted
      t.float :shipping_cost
      t.string :address_name
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.string :address_country
      t.integer :shipping_estimate_id
      t.integer :address_id
      t.string :transaction_id
      t.string :authorization_code

      t.timestamps null: false
    end
  end
end
