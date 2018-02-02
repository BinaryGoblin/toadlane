class AddFlyBuyOrderIdToInspectionDates < ActiveRecord::Migration
  def change
    add_column :inspection_dates, :fly_buy_order_id, :integer
  end
end
