class ShippingEstimate < ActiveRecord::Base
  belongs_to :product
  
  has_one :stripe_order
  
  validates_numericality_of :cost
  
  def get_label
    return " $" + self.cost.to_s + "/unit " + self.description
  end
end