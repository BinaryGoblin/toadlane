class Admin::UsersController < Admin::ApplicationController
  
  layout 'admin_dashboard'

  private
    def set_user
      @user = User.find(params[:id])
    end
    
    def user_params
      params.require(:user)
    end
end