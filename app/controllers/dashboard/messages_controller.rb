class Dashboard::MessagesController < DashboardController
  helper_method :mailbox, :conversation

  def index
    box = params[:box] || 'inbox'

    conversations = mailbox.inbox if box == 'inbox'
    conversations = mailbox.sentbox if box == 'sent'
    conversations = mailbox.trash if box == 'trash'

    @conversations = conversations.paginate(page: params[:page], per_page: params[:count])
  end

  def show
    conversation
    conversation.receipts_for(current_user).last.touch
    conversation.mark_as_read(current_user)
  end

  def reply
    current_user.reply_to_conversation(conversation, conversation_params[:body], conversation_params[:subject])
    receiver = User.find_by_id(params[:user_id])
    MessageMailer.new_message(receiver,
                                conversation_params[:body],
                                conversation_params[:subject],
                                current_user,
                                conversation.id).deliver
    redirect_to :back
  end

  def trash
    conversation.move_to_trash(current_user)
    redirect_to :back
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to :back
  end

  def delete
    conversation.mark_as_deleted(current_user)
    redirect_to :back
  end

  private
    def conversation_params
      params.require(:conversation).permit(:subject, :body)
    end

    def mailbox
      @mailbox ||= current_user.mailbox
    end

    def conversation
      @conversation ||= mailbox.conversations.find(params[:id])
    end
end
