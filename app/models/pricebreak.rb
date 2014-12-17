class Pricebreak < ActiveRecord::Base
  belongs_to :product

  validates :price, :quantity, :product_id, presence: true
end
