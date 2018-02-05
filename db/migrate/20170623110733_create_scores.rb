class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.belongs_to :user
      t.integer :positive, default: 0
      t.integer :negative, default: 0

      t.timestamps null: false
    end
  end
end
