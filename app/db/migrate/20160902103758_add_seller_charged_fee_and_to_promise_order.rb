class AddSellerChargedFeeAndToPromiseOrder < ActiveRecord::Migration
  def change
    add_column :promise_orders, :seller_charged_fee, :float
    add_column :promise_orders, :amount_after_fee_to_seller, :float
  end
end
