# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def additional_seller_removed_notification_email
    group = Group.first
    product = group.product
    user = product.owner
    current_user = User.first
    NotificationMailer.additional_seller_removed_notification_email(product, user, current_user)
  end
end