class AddTaxIdToProducts < ActiveRecord::Migration
  def change
    remove_column :products, :tax_level
    add_reference :products, :tax, index: true
  end
end
