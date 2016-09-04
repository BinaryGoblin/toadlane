class NotificationCreator

  # order can be of any type i.e Promise, Green, Stripe, AMG and EMB
  attr_accessor :order

  ORDER_TYPE = {
    PromiseOrder: 'Fly And Buy',
    GreenOrder: 'Echeck',
    StripeOrder: 'Stripe',
    AmgOrder: 'Credit Card',
    EmbOrder: 'Credit Card (EMB)'
  }

  ORDER_ID_TYPE = {
    PromiseOrder: 'promise_order_id',
    GreenOrder: 'green_order_id',
    StripeOrder: 'stripe_order_id',
    AmgOrder: 'amg_order_id',
    EmbOrder: 'emb_order_id'
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

  def seller_set_inspection_date_to_buyer
    send_to_buyer_seller_request_disapproved
  end

  def buyer_request_inspection_date_to_seller
    send_to_buyer_seller_request_by_buyer
  end

  def seller_confirm_date
    confirm_date_notification_buyer_seller
  end

  private

  def confirm_date_notification_buyer_seller
    @seller.notifications.create({
      user_id: @seller.id,
      title: "You have confirmed #{@buyer.name.title} requested inspection date for product #{@product.name.titleize}."
    })
    @buyer.notifications.create({
      user_id: @buyer.id,
      title: "#{@seller.name.titleize} has confirmed inspection date you requested for product #{@product.name.titleize}."
    })
  end

  def send_to_buyer_seller_request_by_buyer
    @seller.notifications.create({
      user_id: @seller.id,
      title: "#{@buyer.name.titleize} has requested inspection date for product #{@product.name.titleize}. Please check email for more information."
    })
    @buyer.notifications.create({
      user_id: @buyer.id,
      title: "You have requested inspection date for product #{@product.name.titleize}. You will be notified when the seller responds."
    })
  end

  def send_to_buyer_seller_request_disapproved
    @buyer.notifications.create({
      user_id: @buyer.id,
      title: "#{@seller.name.titleize} has disapproved your requested inspection date for product #{@product.name.titleize}. Please check email for more information."
    })
    @seller.notifications.create({
      user_id: @seller.id,
      title: "You have disapproved #{@buyer.name.titleize} set requested inspection date for product #{@product.name.titleize}."
    })
  end

  def notification_create_for_buyer
    @buyer.notifications.create({
      :user_id => @buyer.id,
      get_order_id_type => order.id,
      :title => "You have placed an order with #{get_order_type} for product #{@product.name.titleize}. View your orders tab for more information."
    })
  end

  def notification_create_for_seller
    @seller.notifications.create({
      :user_id => @seller.id,
      get_order_id_type => order.id,
      :title => "#{@buyer.name.titleize} have placed an order with #{get_order_type} for product #{@product.name.titleize}. View your orders tab for more information."
    })
  end

  def get_order_type
    # example=>
    #  string = "abc"
    # # string.to_sym => :abc
    ORDER_TYPE[order.class.name.to_sym]
  end

  def get_order_id_type
    ORDER_ID_TYPE[order.class.name.to_sym]
  end
end
