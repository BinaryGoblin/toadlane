class Admin::Users::CommunicationsController < Admin::UsersController
  layout 'admin_dashboard'
  
  def index
    @users = User.paginate(page: params[:page], per_page: params[:count]).order('id ASC')
  end
end
