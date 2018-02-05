class CreateViewedTasks < ActiveRecord::Migration
  def change
    create_table :viewed_tasks do |t|
      t.belongs_to :user
      t.belongs_to :task

      t.timestamps null: false
    end

    add_index :viewed_tasks, :user_id
    add_index :viewed_tasks, :task_id
    add_index :viewed_tasks, [:user_id, :task_id], unique: true
  end
end
