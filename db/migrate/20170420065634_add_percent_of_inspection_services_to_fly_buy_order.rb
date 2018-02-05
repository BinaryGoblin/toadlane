class AddPercentOfInspectionServicesToFlyBuyOrder < ActiveRecord::Migration
  def change
    add_column :fly_buy_orders, :percentage_of_inspection_service, :integer
    add_column :fly_buy_orders, :inspection_service_cost, :float
    add_column :fly_buy_orders, :inspection_service_comment, :text
  end
end