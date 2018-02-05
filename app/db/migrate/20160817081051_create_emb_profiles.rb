class CreateEmbProfiles < ActiveRecord::Migration
  def change
    create_table :emb_profiles do |t|
      t.integer :user_id
      t.string :username
      t.string :password

      t.timestamps null: false
    end
  end
end
