class UpdateStripeOrders < ActiveRecord::Migration
  def change
    add_column :stripe_profiles, :stripe_customer_id, :string
    add_column :stripe_orders, :address_name, :string
    add_column :stripe_orders, :address_city, :string
    add_column :stripe_orders, :address_state, :string
    add_column :stripe_orders, :address_zip, :string
    add_column :stripe_orders, :address_country, :string
  end
end
