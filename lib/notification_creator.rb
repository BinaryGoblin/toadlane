class NotificationCreator

  # order can be of any type i.e Armor, Green, Stripe, AMG and EMB
  attr_accessor :order

  ORDER_TYPE = {
    'ArmorOrder' => 'Fly And Buy',
    'GreenOrder' => 'Echeck',
    'StripeOrder' => 'Stripe',
    'AmgOrder' => 'Credit Card',
    'EmbOrder' => 'Credit Card (EMB)'
  }

  def initialize(order)
    self.order = order
    @product = order.product
    @seller = order.seller
    @buyer = order.buyer
  end

  def after_order_created
    notification_create_for_buyer
    notification_create_for_seller
  end

  private

  def notification_create_for_buyer
    @buyer.notifications.create({
      user_id: @buyer.id,
      armor_order_id: order.id,
      title: "You have placed an order with #{get_order_type} for product #{@product.name.titleize}. View your orders tab for more information."
    })
  end

  def notification_create_for_seller
    @seller.notifications.create({
      user_id: @seller.id,
      armor_order_id: order.id,
      title: "#{@buyer.name.titleize} have placed an order with #{get_order_type} for product #{@product.name.titleize}. View your orders tab for more information."
    })
  end

  def get_order_type
    ORDER_TYPE[order.class.name]
  end
end
