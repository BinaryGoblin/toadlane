class AddOffersToProducts < ActiveRecord::Migration
  def change
    add_column :products, :request_id, :integer
  end
end
