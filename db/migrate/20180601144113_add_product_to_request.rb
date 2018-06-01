class AddProductToRequest < ActiveRecord::Migration
  def change
    add_reference :requests, :product, index: true, foreign_key: true
  end
end
