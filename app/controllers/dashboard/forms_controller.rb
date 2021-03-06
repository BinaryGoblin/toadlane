class Dashboard::FormsController < DashboardController
	def index
		set_user
	end

	def update
	  set_user
		if user_params[:certificate].present?
      if @user.certificate
        @user.certificate.update(uploaded_file: user_params[:certificate])
      else
        certificate = Certificate.new
        certificate.uploaded_file = user_params[:certificate]
        @user.certificate = certificate
      end

      user_params.delete(:certificate)
    end

    if user_params[:certificate_delete].present?
      current_user.certificate.destroy
      user_params.delete(:certificate_delete)
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to dashboard_payments_path }
      else
        format.html { render action: 'show' }
    	end
    end
	end

	private
	  def set_user
	    @user = current_user
	  end

	  def user_params
	    params.require(:user).permit!
	  end
end
