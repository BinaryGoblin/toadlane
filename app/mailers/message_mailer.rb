class MessageMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default from: "Toadlane Notifications hello@toadlane.com"

  def new_message(user, message, subject, sender, conversation_id)
    @user = user
    @message = message
    @subject = subject
    @sender = sender
    @message_url = dashboard_message_url(conversation_id)
    mail to: @user.email , subject: "New Message from #{@sender.name || @sender.email}"
  end
end
