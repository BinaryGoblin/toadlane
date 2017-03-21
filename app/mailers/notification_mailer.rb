class NotificationMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def product_create_notification_email(product, user)
    @user = user
    @product = product
    mail to: @user.email, subject: "#{@product.name} just listed for sale!"
  end
end
