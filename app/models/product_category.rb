class ProductCategory < ActiveRecord::Base
  self.table_name = 'product_categories'

  belongs_to :product
  belongs_to :category
end
