class NotificationMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default from: 'Toadlane Notifications hello@toadlane.com'

  def product_create_notification_email(product, user)
    @user = user
    @product = product
    mail to: @user.email, subject: 'Added new product of your interest'
  end
end
