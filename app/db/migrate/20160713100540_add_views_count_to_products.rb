class AddViewsCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :views_count, :integer, default: 0
  end
end
