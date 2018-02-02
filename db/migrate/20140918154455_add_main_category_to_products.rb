class AddMainCategoryToProducts < ActiveRecord::Migration
  def change
    add_column :products, :main_category, :integer
  end
end
