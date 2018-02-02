class AddSubclassesToShippingEstimates < ActiveRecord::Migration
  def change
    add_column :shipping_estimates, :type, :string, null: false, default: "per_unit"
  end
end
