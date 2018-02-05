# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def additional_seller_removed_notification_email
    group = Group.first
    product = group.product
    user = product.owner
    current_user = User.first
    admins = product.group_admins

    NotificationMailer.additional_seller_removed_notification_email(product, user, current_user, admins)
  end

  def group_product_removed_notification_email
    group = Group.first
    product = group.product
    user = product.owner
    current_user = User.first
    admins = product.group_admins
    param_hash = {group: group.name, product: product, group_seller: user, current_user: current_user, admins: admins}

    NotificationMailer.group_product_removed_notification_email(param_hash)
  end

  def group_removed_notification_email
    group = Group.first
    product = group.product
    user = product.owner
    current_user = User.first
    admins = product.group_admins
    param_hash = {group: group.name, product: product, group_seller: user, current_user: current_user, admins: admins}

    NotificationMailer.group_removed_notification_email(param_hash)
  end

  def group_product_expired_notification_email
    group = Group.first
    product = group.product
    user = product.owner
    admins = product.group_admins

    NotificationMailer.group_product_expired_notification_email(product, user, admins)
  end

  def product_create_notification_email
    product = Product.first
    user = product.owner

    NotificationMailer.product_create_notification_email(product, user)
  end

  def request_create_notification_email
    product = Product.first
    user = product.owner

    NotificationMailer.request_create_notification_email(product, user)
  end

  def offer_notification_email
    offer = Product.where(status_characteristic: 'offer').first
    request = offer.request

    NotificationMailer.offer_notification_email(offer, request)
  end

  def product_expired_notification_to_owner
    product = Product.first

    NotificationMailer.product_expired_notification_to_owner(product)
  end
end
