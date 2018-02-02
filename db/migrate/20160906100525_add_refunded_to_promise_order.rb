class AddRefundedToPromiseOrder < ActiveRecord::Migration
  def change
    add_column :promise_orders, :refunded, :boolean, default: false
  end
end
