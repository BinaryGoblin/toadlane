# == Schema Information
#
# Table name: shipping_estimates
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  cost        :float
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  type        :string           default("PerUnit"), not null
#

class PerUnit < ShippingEstimate
  def calculate_shipping(stripe_order)
    stripe_order.shipping_cost = self.cost * stripe_order.count
    stripe_order.save
  end

  def get_label
    return " $" + sprintf( "%0.02f", self.cost) + "/unit " + self.description
  end
end
