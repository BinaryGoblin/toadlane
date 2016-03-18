class CreateStripeCustomers < ActiveRecord::Migration
  def change
    create_table :stripe_customers do |t|
      t.belongs_to :stripe_profile
      t.belongs_to :user
      t.string :stripe_customer_id
      
      t.timestamps null: false
    end
    
    remove_column :stripe_profiles, :stripe_customer_id, :string
  end
end
