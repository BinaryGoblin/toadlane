class MessagesController < ApplicationController
  before_filter :authenticate_user!, except: :inbound
  before_action :check_if_user_active
  before_action :check_terms_of_service
  skip_before_action :verify_authenticity_token, only: :inbound
  helper_method :mailbox, :conversation

  def create
    product = Product.find message_params[:product_id]
    if product.group.present?
      product.group.group_sellers.each do |seller|
        unless seller.role.name == Role::PRIVATE_SELLER || seller.role.name == Role::PRIVATE_SUPPLIER
          send_message_to_user seller.user
        end
      end
    end
    send_message_to_user product.user
    redirect_to :back
  end

  def group_member_message
    group_member = GroupSeller.where(id: message_params[:group_member_id]).first
    send_message_to_user group_member.user
    redirect_to :back
  end

  def group_admin_message
    @message = params[:message]
    @admins = params[:admins].join(',')
  end

  def send_group_admin_message
    admin_ids = message_params[:admins].split(',')
    admin_ids.each do |admin_id|
      user = User.where(id: admin_id).first
      send_message_to_user(user)
    end
    flash[:notice] = 'Your message send successfully.'
    redirect_to :back
  end

  def inbound
    if request.post? && params[:message].present?
      if params["message"]["FromName"] != "Postmarkapp Support"
        conversation = Mailboxer::Conversation.find_by_id(params["message"]["MailboxHash"].to_i)
        sender = User.find_by_email(params["message"]["From"])

        sender.reply_to_conversation(conversation, params["message"]["TextBody"], params["message"]["Subject"])
        receiver_id = conversation.messages.where.not(sender_id: sender.id).first.sender_id
        receiver = User.find_by_id(receiver_id)
        MessageMailer.new_message(receiver,
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

  def individual_user
    user = User.find(params[:user_id])
    send_message_to_user(user)

    flash[:notice] = "Your message to (#{user.name}) has been sent."
    redirect_to :back
  end

  private

  def message_params
    params.require(:message).permit(:group_member_id, :product_id, :subject, :body, :admins)
  end

  def send_message_to_user(user)
    receiver = user
    receipt = current_user.send_message receiver, message_params[:body], message_params[:subject]
    MessageMailer.new_message(receiver,
      message_params[:body],
      message_params[:subject],
      current_user,
    receipt.notification.conversation.id).deliver_later
  end

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(60)
  end
end
