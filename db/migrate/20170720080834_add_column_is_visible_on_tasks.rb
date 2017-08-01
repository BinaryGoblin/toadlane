class AddColumnIsVisibleOnTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :is_visible, :boolean, default: true
    add_column :tasks, :score, :integer, default: 0
  end
end
