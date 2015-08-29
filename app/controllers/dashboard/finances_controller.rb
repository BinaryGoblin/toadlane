class Dashboard::FinancesController < DashboardController
  def show
    @user = current_user
  end
  
  def create
    if params[:accept].present? && params[:accept] == "1"
      respond_to do |format|
        if params[:loan_amount].present? && params[:business_years].present? && params[:monthly_revenue].present?
          FinancesMailer.multivision_application_email(current_user, params[:loan_amount], params[:business_years], params[:monthly_revenue]).deliver
          
          format.html { redirect_to dashboard_finances_path(success?: '1') }
        else
          format.html { redirect_to dashboard_finances_path(success?: '2') }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_finances_path(success?: '3') }
      end
    end
  end
end