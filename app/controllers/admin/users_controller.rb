class Admin::UsersController < Admin::ApplicationController
  private
    def set_user
      @user = User.find(params[:id])
    end
    
    def user_params
      params.require(:user)
    end
end