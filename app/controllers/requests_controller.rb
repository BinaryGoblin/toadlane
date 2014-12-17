class RequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    data = Request.new(
      receiver_id: request_params[:user_id], 
      sender_id: current_user.id, 
      subject: request_params[:subject], 
      body: request_params[:body]
    )

    if data.save
      redirect_to :back if data.update conversation: data.id
    end
  end

  private
    def request_params
      params.require(:request).permit(:user_id, :subject, :body)
    end
end
