module ProductHelper

  def get_shipping_cost(quantity, shipping_cost)
    quantity.to_i * shipping_cost.to_f
  end

  def get_subtotal(unit_price, quantity)
    quantity.to_i * unit_price
  end
end
