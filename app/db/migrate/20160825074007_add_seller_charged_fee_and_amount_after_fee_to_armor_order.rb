class AddSellerChargedFeeAndAmountAfterFeeToArmorOrder < ActiveRecord::Migration
  def change
    add_column :armor_orders, :seller_charged_fee, :float
    add_column :armor_orders, :amount_after_fee_to_seller, :float
  end
end
