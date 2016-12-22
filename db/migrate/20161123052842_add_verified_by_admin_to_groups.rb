class AddVerifiedByAdminToGroups < ActiveRecord::Migration
  def change
  	add_column :groups, :verified_by_admin, :boolean, default: false
  end
end
