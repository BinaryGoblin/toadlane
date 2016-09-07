class AddFeesRelatedFieldsToPromiseOrder < ActiveRecord::Migration
  def change
    add_column :promise_orders, :ach_fee_amount, :float
    add_column :promise_orders, :transaction_fee_amount, :float
    add_column :promise_orders, :fraud_protection_fee_amount, :float
    add_column :promise_orders, :end_user_support_fee_amount, :float
  end
end
