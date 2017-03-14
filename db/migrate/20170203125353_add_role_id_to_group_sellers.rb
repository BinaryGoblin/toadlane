class AddRoleIdToGroupSellers < ActiveRecord::Migration
  def change
    add_column :group_sellers, :role_id, :integer
  end
end
