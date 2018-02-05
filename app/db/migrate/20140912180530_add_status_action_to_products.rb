class AddStatusActionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :status_action, :string
  end
end
