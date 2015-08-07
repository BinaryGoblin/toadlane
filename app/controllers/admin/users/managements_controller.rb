class Admin::Users::ManagementsController < Admin::UsersController
  def index
    @users = Role.find_by(name: :user).users.paginate(page: params[:page], per_page: params[:count]).order('id ASC')
  end
end
