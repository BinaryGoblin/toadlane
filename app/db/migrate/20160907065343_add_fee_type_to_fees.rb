class AddFeeTypeToFees < ActiveRecord::Migration
  def change
    add_column :fees, :fee_type, :string
  end
end
