class MessagesController < ApplicationController
  before_filter :authenticate_user!, except: :inbound
  before_action :check_if_user_active
  before_action :check_terms_of_service
  skip_before_action :verify_authenticity_token, only: :inbound

  def create
    product = Product.find message_params[:product_id]
    message = nil
    if product.group.present?
      product.group.group_sellers.each do |seller|
        unless seller.role.name == Role::PRIVATE_SELLER || seller.role.name == Role::PRIVATE_SUPPLIER
          message = "Your message to (#{seller.user.name}) has been sent."
          send_message_to_user seller.user
        end
      end
    else
      message = "Your message to (#{product.user.name}) has been sent."
      send_message_to_user product.user
    end
    flash[:notice] = message
    redirect_to :back
  end

  def group_member_message
    group_member = GroupSeller.find(message_params[:group_member_id])
    send_message_to_user group_member.user
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

  private
  def message_params
    params.require(:message).permit(:group_member_id, :product_id, :subject, :body)
  end

  def send_message_to_user user
    receiver = user
    receipt = current_user.send_message receiver, message_params[:body], message_params[:subject]
    MessageMailer.new_message(receiver,
      message_params[:body],
      message_params[:subject],
      current_user,
    receipt.notification.conversation.id).deliver_now
  end
end
