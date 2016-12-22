class AddGroupIdToGroupSellers < ActiveRecord::Migration
  def change
  	add_column :group_sellers, :group_id, :integer
  end
end
