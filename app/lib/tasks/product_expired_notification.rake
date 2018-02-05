desc 'Product expired email notification'
task product_expired_notification: :environment do
  expired_products = Product.active.expired_yesterday

  expired_products.each do |expired_product|
    make_product_inactive(expired_product)
  end
end

private

def make_product_inactive(expired_product)
  expired_product.update_attribute(:status, false)
  NotificationMailer.product_expired_notification_to_owner(expired_product).deliver_later
  if expired_product.is_group_product?
    admins = expired_product.group_admins
    expired_product.group.group_sellers.each do |group_seller|
      NotificationMailer.group_product_expired_notification_email(expired_product, group_seller.user, admins).deliver_later
    end
  end
end