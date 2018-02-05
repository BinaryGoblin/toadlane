class AddFieldPrivateSellerToGroupSellers < ActiveRecord::Migration
  def change
  	add_column :group_sellers, :private_seller, :boolean, default: false
  end
end
