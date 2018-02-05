class CreateAdditionalSellerFees < ActiveRecord::Migration
  def change
    create_table :additional_seller_fees do |t|
    	t.integer :group_id
    	t.integer :group_seller_id
    	t.decimal :value

      t.timestamps null: false
    end
  end
end
