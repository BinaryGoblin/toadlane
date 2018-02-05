class RemoveUserFromShippingEstimate < ActiveRecord::Migration
  def change
    remove_column :shipping_estimates, :user_id
  end
end
