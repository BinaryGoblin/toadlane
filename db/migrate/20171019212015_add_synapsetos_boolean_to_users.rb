class AddSynapsetosBooleanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :Synapsetos, :boolean
  end
end
