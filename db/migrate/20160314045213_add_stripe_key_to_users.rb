class AddStripeKeyToUsers < ActiveRecord::Migration
  def change
    create_table :stripe_profiles do |t|
      t.string :stripe_publishable_key
      t.string :stripe_uid
      t.string :stripe_access_code
      t.references :user, index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
