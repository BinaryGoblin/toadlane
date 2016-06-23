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
    binding.pry
    response = params
    conversation_id = response["MailboxHash"].to_i
    conversation = Mailboxer::Conversation.find_by_id(conversation_id)
    sender = User.find_by_email(response["From"])
    reply_dashboard_message_path(conversation.messages.last)
    # conversation.messages.create(type: 'Mailboxer::Message',
    #                               subject: response["Subject"],
    #                               sender_type: 'User',
    #                               sender_id: sender.id
    #                               body: response["TextBody"] )

  end

  private
    def message_params
      params.require(:message).permit(:user_id, :subject, :body)
    end
end
