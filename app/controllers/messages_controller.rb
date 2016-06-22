class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_if_user_active
  before_action :check_terms_of_service

  def create
    user = User.find message_params[:user_id]
    receipt = current_user.send_message user, message_params[:body], message_params[:subject]
    MessageMailer.new_message(user,
                                conversation_params[:body],
                                conversation_params[:subject],
                                current_user,
                                receipt.notification.conversation.id).deliver
    redirect_to :back
  end

  private
    def message_params
      params.require(:message).permit(:user_id, :subject, :body)
    end
end
