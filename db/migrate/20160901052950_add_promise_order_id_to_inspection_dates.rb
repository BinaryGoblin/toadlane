class AddPromiseOrderIdToInspectionDates < ActiveRecord::Migration
  def change
    add_column :inspection_dates, :promise_order_id, :integer
  end
end
