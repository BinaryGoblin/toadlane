class NotificationMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def product_create_notification_email(product, user)
    @user = user
    @product = product
    mail to: @user.email, subject: "#{@product.name} just listed for sale!"
  end

  def additional_seller_removed_notification_email(product, user, current_user)
    @product = product
    @user = user
    @current_user = current_user

    mail to: @user.email, subject: "#{@current_user.name.titleize} removed you from a group"
  end
end
