class RenameArmorProfileFields < ActiveRecord::Migration
  def change
    rename_column :armor_profiles, :armor_account, :armor_account_id
    rename_column :armor_profiles, :armor_user, :armor_user_id
  end
end
