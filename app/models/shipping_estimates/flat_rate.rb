class FlatRate < ShippingEstimate
  def calculate_shipping(stripe_order)
    stripe_order.shipping_cost = self.cost
    stripe_order.save
  end
  
  def get_label
    return " $" + sprintf( "%0.02f", self.cost) + " Flat Rate " + self.description
  end
end