class AddNotifiedToGroupSellers < ActiveRecord::Migration
  def change
    add_column :group_sellers, :notified, :boolean, default: false
  end
end
