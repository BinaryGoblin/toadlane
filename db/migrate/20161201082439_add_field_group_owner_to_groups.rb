class AddFieldGroupOwnerToGroups < ActiveRecord::Migration
  def change
  	add_column :groups, :group_owner_id, :integer
  end
end
