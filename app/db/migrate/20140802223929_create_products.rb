class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :slug
      t.string :sku
      t.string :description
      t.datetime :start_date
      t.datetime :end_date
      t.float :unit_price
      t.string :tax_level
      t.boolean :status, default: true
# t.integer :amount
# t.integer :sold_out
# t.string :width
# t.string :height
# t.string :depth
# t.string :weight
      t.references :user, index: true
#no need more      t.references :category, index: true

      t.timestamps
    end
  end
end
