class MessageMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default :from     => 'Toadlane Notifications hello@toadlane.com',
          :reply_to => 'c8b7ddb781077404c27659d9ef85d353@inbound.postmarkapp.com'

  def new_message(user, message, subject, sender, conversation_id)
    @user = user
    @message = message
    @subject = subject
    @sender = sender
    @message_url = dashboard_message_url(conversation_id)
    mail( to: @user.email,
          subject: "New Message from #{@sender.name || @sender.email}",
          reply_to: "c8b7ddb781077404c27659d9ef85d353+#{conversation_id}@inbound.postmarkapp.com")
  end
end
