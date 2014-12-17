class MessageMailer < ActionMailer::Base
  default from: "aphtekas.storage@gmail.com"

  def send_new_message(user, token)
#    email = user.email
#    @token = token
#    @user = user
#    mail to: email , subject: "New event - Add User Account"
  end
end

