module ProductHelper

  def get_shipping_cost(quantity, shipping_cost)
    quantity.to_i * shipping_cost.to_f
  end
end
