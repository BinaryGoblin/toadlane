class RemoveStripeProfileFromStripeCustomers < ActiveRecord::Migration
  def change
    remove_column :stripe_customers, :stripe_profile_id
  end
end
