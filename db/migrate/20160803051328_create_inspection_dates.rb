class CreateInspectionDates < ActiveRecord::Migration
  def change
    create_table :inspection_dates do |t|
      t.datetime :date
      t.string :creator_type
      t.integer :product_id
      t.integer :armor_order_id
      t.boolean :approved

      t.timestamps null: false
    end
  end
end
