class CreateShippingEstimates < ActiveRecord::Migration
  def change
    create_table :shipping_estimates do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
      t.float :cost
      t.text :description, limit: 1000
      
      t.timestamps null: false
    end
    
    remove_column :stripe_orders, :shipping_request
    remove_column :stripe_orders, :shipping_details
    remove_column :stripe_orders, :shipping_address
    
    add_reference :stripe_orders, :shipping_estimate, index: true, foreign_key: true
    add_reference :stripe_orders, :address, index: true, foreign_key: true
  end
end
