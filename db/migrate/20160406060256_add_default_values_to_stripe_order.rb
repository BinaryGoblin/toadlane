class AddDefaultValuesToStripeOrder < ActiveRecord::Migration
  def change
    change_column :stripe_orders, :deleted, :boolean, null: false, default: false
  end
end
