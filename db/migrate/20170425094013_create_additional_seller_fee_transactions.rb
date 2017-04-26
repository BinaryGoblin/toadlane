class CreateAdditionalSellerFeeTransactions < ActiveRecord::Migration
  def change
    create_table :additional_seller_fee_transactions do |t|
      t.belongs_to :fly_buy_order
      t.belongs_to :user
      t.integer :group_id
      t.string :synapse_transaction_id
      t.float :fee
      t.boolean :is_paid, default: false

      t.timestamps null: false
    end
  end
end
