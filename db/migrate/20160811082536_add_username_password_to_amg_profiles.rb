class AddUsernamePasswordToAmgProfiles < ActiveRecord::Migration
  def change
    add_column :amg_profiles, :username, :string
    add_column :amg_profiles, :password, :string
  end
end
