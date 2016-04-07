class Dashboard::TermsOfServicesController < DashboardController
  skip_before_action :check_terms_of_service
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def update_terms
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(user_term_params)
        format.html { redirect_to products_path }
      else
        format.html { render :index }
      end
    end
  end

  private
    def user_term_params
      params.require(:user).permit(:terms_of_service, :terms_accepted_at)
    end
end