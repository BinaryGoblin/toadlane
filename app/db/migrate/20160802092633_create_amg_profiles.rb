class CreateAmgProfiles < ActiveRecord::Migration
  def change
    create_table :amg_profiles do |t|
      t.string :amg_api_key
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
