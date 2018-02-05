class FixDefaultShippingEstimateType < ActiveRecord::Migration
  def change
    change_column :shipping_estimates, :type, :string, null: false, default: "PerUnit"
  end
end
