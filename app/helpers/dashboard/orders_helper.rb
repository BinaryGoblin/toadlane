module Dashboard::OrdersHelper
  def current_user_is_a_seller?(order)
    current_user == order.seller
  end

  def current_user_is_a_buyer?(order)
    current_user == order.buyer
  end
end