class CreateGreenChecks < ActiveRecord::Migration
  def change
    create_table :green_checks do |t|
      t.string :result
      t.string :result_description
      t.string :check_number
      t.string :check_id
      t.integer :green_order_id

      t.timestamps null: false
    end
  end
end
