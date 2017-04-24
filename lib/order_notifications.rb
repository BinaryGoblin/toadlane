class OrderNotifications
  attr_reader :order

  def initialize(order, user)
    @order = order
    @user = user
  end

  def order_canceled
    send_order_canceled_notifications
  end

  private
  def send_order_canceled_notifications
    @user.notifications.create({
      title: "Order ##{order.id} for '#{order.product.name}' has been cancelled because the money was not verified 24 hours prior to inspection."
    })
  end
end