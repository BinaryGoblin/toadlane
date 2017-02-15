class ServiceMailer < ApplicationMailer
  default from: "Toadlane Notifications toad.b2b@gmail.com"

  def send_new_service_info(user, products)
   email = user.email
   @products = products
   @user = user
   mail to: email, subject: 'New products'
  end
end
