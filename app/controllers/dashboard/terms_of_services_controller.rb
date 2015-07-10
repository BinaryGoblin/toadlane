class Dashboard::TermsOfServicesController < DashboardController
  before_action :set_user
  skip_before_action :check_terms_of_service

  def index
  end

  def update_terms
    respond_to do |format|
      if @user.update_attributes(user_term_params)
        format.html { redirect_to products_path }
      else
        format.html { render :index }
      end
    end
  end

  private
    def set_user
      @user = current_user
    end
    def user_term_params
      params.require(:user).permit(:terms_of_service, :terms_accepted_at)
    end
end