class AddPromiseItemIdToPromiseOrder < ActiveRecord::Migration
  def change
    add_column :promise_orders, :promise_item_id, :string
  end
end
