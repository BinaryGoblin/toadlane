class CreateArmorInvoices < ActiveRecord::Migration
  def change
    create_table :armor_invoices do |t|
      t.integer :buyer_id
      t.integer :seller_id
      t.references :product, index: true
      t.float :unit_price
      t.integer :count		# as 'quantity' in psd
      t.float :amount		# as 'total' in psd

      t.timestamps
    end
  end
end
