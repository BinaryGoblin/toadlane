class ChangeArmorUserToBigint < ActiveRecord::Migration
  def change
    change_column :armor_profiles, :armor_user, :bigint
  end
end
