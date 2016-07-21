class AddProductIdToCertificates < ActiveRecord::Migration
  def change
    add_column :certificates, :product_id, :integer
  end
end
