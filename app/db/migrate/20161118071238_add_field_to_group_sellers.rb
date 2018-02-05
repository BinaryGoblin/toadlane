class AddFieldToGroupSellers < ActiveRecord::Migration
  def change
  	add_column :group_sellers, :accept_deal, :boolean
  end
end
