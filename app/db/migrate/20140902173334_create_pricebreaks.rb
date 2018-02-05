class CreatePricebreaks < ActiveRecord::Migration
  def change
    create_table :pricebreaks do |t|
      t.integer :quantity
      t.float :price
      t.references :product, index: true

      t.timestamps
    end
  end
end
