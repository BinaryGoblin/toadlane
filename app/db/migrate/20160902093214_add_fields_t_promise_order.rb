class AddFieldsTPromiseOrder < ActiveRecord::Migration
  def change
    add_column :promise_orders, :inspection_complete, :boolean, default: false
    add_column :promise_orders, :funds_in_escrow, :boolean, default: false
  end
end
