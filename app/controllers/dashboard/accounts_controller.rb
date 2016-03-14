class Dashboard::AccountsController < DashboardController
  def index
    set_user
  end
  
  private
    def set_user
      @user = current_user
    end

    def user_params
      params.require(:user).permit!
    end
end