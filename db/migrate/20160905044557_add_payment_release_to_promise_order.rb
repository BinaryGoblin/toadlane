class AddPaymentReleaseToPromiseOrder < ActiveRecord::Migration
  def change
    add_column :promise_orders, :payment_release, :boolean, default: false
  end
end
