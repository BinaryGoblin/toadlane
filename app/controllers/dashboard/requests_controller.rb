class Dashboard::RequestsController < DashboardController
  def index
    box = params[:box] || 'inbox'

    unless params[:box]
      redirect_to dashboards_requests_path(box: 'inbox')
    end

    if box == 'inbox'
      conversations = Request.where(receiver_id: current_user.id)
    elsif box == 'sent'
      conversations =  Request.where(sender_id: current_user.id)
    end

    @conversations = conversations.order('created_at DESC').uniq(&:conversation)
  end

  def show
    @conversation = Request.where(conversation: params[:id]).order(:created_at)
  end

  def reply
    data = Request.new(
      sender_id: current_user.id,
      conversation: request_params[:conversation],
      receiver_id: request_params[:receiver_id],
      subject: request_params[:subject],
      body: request_params[:body]
    )

    redirect_to :back if data.save
  end

  private
    def request_params
      params.require(:request).permit(:conversation, :receiver_id, :subject, :body)
    end
end
