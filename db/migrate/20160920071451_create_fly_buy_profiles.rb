class CreateFlyBuyProfiles < ActiveRecord::Migration
  def change
    create_table :fly_buy_profiles do |t|
      t.string :synapse_user_id
      t.integer :user_id
      
      t.timestamps null: false
    end
  end
end
