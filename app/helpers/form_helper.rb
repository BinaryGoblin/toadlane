module FormHelper
  def setup_user(user)
    1.times { user.addresses.build }
    user
  end
  
  def setup_product(product)
    1.times { product.shipping_estimates.build }
    product
  end
end