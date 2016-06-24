class MessagesController < ApplicationController
  before_filter :authenticate_user!, except: :inbound
  before_action :check_if_user_active
  before_action :check_terms_of_service
  skip_before_action :verify_authenticity_token, only: :inbound

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
    if request.post? && params[:message].present?
      if params["message"]["FromName"] != "Postmarkapp Support"
        conversation = Mailboxer::Conversation.find_by_id(params["message"]["MailboxHash"].to_i)
        sender = User.find_by_email(params["message"]["From"])

        sender.reply_to_conversation(conversation, params["message"]["TextBody"], params["message"]["Subject"])
        recipient_id = conversation.messages.where.not(sender_id: sender.id).first.sender_id
        recipient = User.find_by_id(recipient_id)
        MessageMailer.new_message(recipient,
                                    params["message"]["TextBody"],
                                    params["message"]["Subject"],
                                    sender,
                                    conversation.id).deliver
      end
      render nothing: true, status: 200
    else
      redirect_to root_path
    end
  end

  private
    def message_params
      params.require(:message).permit(:user_id, :subject, :body)
    end
end
