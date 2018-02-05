class ChangeArmorAccountToBigint < ActiveRecord::Migration
  def change
    change_column :armor_profiles, :armor_account, :bigint
  end
end
