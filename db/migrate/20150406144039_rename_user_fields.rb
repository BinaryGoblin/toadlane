class RenameUserFields < ActiveRecord::Migration
  def change
    rename_column :users, :location, :address
    rename_column :users, :zip_code, :postal_code
  end
end
