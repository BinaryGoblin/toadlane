class ChangeTaxesToFees < ActiveRecord::Migration
  def change
    remove_reference :products, :tax
    drop_table :taxes
    
    create_table(:fees) do |t|
      t.string :module_name
      t.decimal :value, precision: 5, scale: 3
      
      t.timestamps null: false
    end
  end
end
