class MessageMailer < ActionMailer::Base
  default from: "hello@toadlane.com"

  def new_message(user, message, subject, sender)
    @user = user
    @message = message
    @subject = subject
    @sender = sender
    mail to: @user.email , subject: "New Message from #{@sender.name} in Toadlane"
  end
end

