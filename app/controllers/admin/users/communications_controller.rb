class Admin::Users::CommunicationsController < Admin::UsersController
  
  def index
    @users = User.paginate(page: params[:page], per_page: params[:count]).order('id ASC')
  end
end
