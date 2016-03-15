class CreateStripeOrders < ActiveRecord::Migration
  def change
    create_table :stripe_orders do |t|
      t.belongs_to :buyer
      t.belongs_to :seller
      t.belongs_to :product
      t.string :stripe_charge_id
      t.integer :status, default: 0
      t.float :unit_price
      t.integer :count
      t.float :fee
      t.float :rebate
      t.float :total
      t.string :summary, limit: 100
      t.text :description, limit: 1000
      t.text :shipping_address, limit: 1000
      t.text :shipping_request, limit: 5000
      t.text :shipping_details, limit: 5000
      t.string :tracking_number
      t.boolean :deleted
      
      t.timestamps null: false
    end
  end
end
