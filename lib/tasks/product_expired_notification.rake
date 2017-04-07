desc 'Group Product expired email notification to group members'
task product_expired_notification: :environment do
  expired_products = Product.offer_expired

  expired_products.each do |expired_product|
    if expired_product.is_group_product?
      admins = expired_product.group_admins
      expired_product.group.group_sellers.each do |group_seller|
        NotificationMailer.group_product_expired_notification_email(expired_product, group_seller.user, admins).deliver_later
      end
    end
  end
end