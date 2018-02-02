class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.belongs_to :user
      t.belongs_to :taskable, polymorphic: true
      t.text :description

      t.timestamps null: false
    end
  end
end
