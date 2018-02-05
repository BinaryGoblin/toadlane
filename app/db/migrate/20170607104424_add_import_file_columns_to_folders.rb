class AddImportFileColumnsToFolders < ActiveRecord::Migration
  def change
    add_attachment :folders, :import
  end
end
