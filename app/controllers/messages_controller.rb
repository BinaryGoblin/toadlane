class MessagesController < ApplicationController
  before_filter :authenticate_user!, except: :inbound
  before_action :check_if_user_active
  before_action :check_terms_of_service

  def create
    user = User.find message_params[:user_id]
    receipt = current_user.send_message user, message_params[:body], message_params[:subject]
    MessageMailer.new_message(user,
                                message_params[:body],
                                message_params[:subject],
                                current_user,
                                receipt.notification.conversation.id).deliver
    redirect_to :back
  end

  def inbound
    conversation = Mailboxer::Conversation.find_by_id(params["MailboxHash"].to_i)
    sender = User.find_by_email(params["From"])

    sender.reply_to_conversation(conversation, params["TextBody"], params["Subject"])
    recipient_id = conversation.messages.where.not(sender_id: sender.id).first.sender_id
    recipient = User.find_by_id(recipient_id)
    MessageMailer.new_message(recipient,
                                params["TextBody"],
                                params["Subject"],
                                sender,
                                conversation.id).deliver
    render nothing: true, status: 200
  end

  private
    def message_params
      params.require(:message).permit(:user_id, :subject, :body)
    end
end
