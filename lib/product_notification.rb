class ProductNotification
  attr_accessor :product, :users

  def initialize(product, user)
    @product = product
    @user = user
  end

  def product_created
    send_product_create_notifications
  end

  private
  def send_product_create_notifications
    @product.notifications.create({
      user_id: @user.id,
      title: "#{@product.owner.name.titleize} has added product #{@product.name.titleize}."
    })
  end
end