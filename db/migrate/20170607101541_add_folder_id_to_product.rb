class AddFolderIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :folder_id, :integer
  end
end
