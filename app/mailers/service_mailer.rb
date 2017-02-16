class ServiceMailer < ApplicationMailer

  def send_new_service_info(user, products)
   email = user.email
   @products = products
   @user = user
   mail to: email, subject: 'New products'
  end
end
