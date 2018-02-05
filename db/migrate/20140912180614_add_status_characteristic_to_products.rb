class AddStatusCharacteristicToProducts < ActiveRecord::Migration
  def change
    add_column :products, :status_characteristic, :string
  end
end
