class CreateArmorProfiles < ActiveRecord::Migration
  def change
    create_table :armor_profiles do |t|
      t.integer :armor_account
      t.integer :armor_user
      t.references :user, index: true

      t.timestamps
    end
  end
end
