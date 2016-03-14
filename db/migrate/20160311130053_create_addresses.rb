class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :user, index: true, foreign_key: true
      t.string   "name"
      t.string   "line1"
      t.string   "line2"
      t.string   "zip"
      t.string   "city"
      t.string   "state"
      t.string   "country"
      
      t.timestamps null: false
    end
  end
end