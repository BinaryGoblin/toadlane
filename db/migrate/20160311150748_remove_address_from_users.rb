class RemoveAddressFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :address, :string
    remove_column :users, :postal_code, :string
    remove_column :users, :city, :string
    remove_column :users, :state, :string
    remove_column :users, :country, :string
  end
end
