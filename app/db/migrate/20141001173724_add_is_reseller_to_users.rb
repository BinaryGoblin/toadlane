class AddIsResellerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_reseller, :boolean, default: false
  end
end
