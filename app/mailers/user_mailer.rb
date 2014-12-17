class UserMailer < ActionMailer::Base
  default from: "aphtekas.storage@gmail.com"

  def event_notification_user(user, token)
    email = user.email
    @token = token
    @user = user
    mail to: email , subject: "New event - Add User Account"
  end

  def event_notification_admin(user, token)
    email = user.email
    @token = token
    @user = user
    mail to: email , subject: "New event - Add Admin Account"
  end
end

