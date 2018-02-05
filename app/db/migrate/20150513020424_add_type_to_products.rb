class AddTypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :type, :integer, default: 'on_sale'
  end
end
