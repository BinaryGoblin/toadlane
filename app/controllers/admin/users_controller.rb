class Admin::UsersController < Admin::ApplicationController
  private
    def set_user
      @user = User.find(params[:id])
    end
end