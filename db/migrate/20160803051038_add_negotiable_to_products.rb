class AddNegotiableToProducts < ActiveRecord::Migration
  def change
    add_column :products, :negotiable, :boolean
  end
end
