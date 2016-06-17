class CreateGreenProfiles < ActiveRecord::Migration
  def change
    create_table :green_profiles do |t|
      t.string :green_client_id
      t.string :green_api_password
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
