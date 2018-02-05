class AddImportStatusColumnToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :import_status, :string
    add_column :folders, :error_message, :string
  end
end
