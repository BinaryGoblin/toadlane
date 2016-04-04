class ShippingEstimate < ActiveRecord::Base
  belongs_to :product
  
  has_one :stripe_order
  
  validates_numericality_of :cost
end