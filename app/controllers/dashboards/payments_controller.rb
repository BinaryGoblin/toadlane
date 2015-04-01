class Dashboards::PaymentsController < ApplicationController
	before_action :set_user, only: [:show, :update]
	layout 'user_dashboard'

	def index
		@user = current_user
	end

	def update
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
       
        if @user.armor_profile.present?
          data = ArmorService.new
          data.update_user({
            'account' => current_user.armor_profile.armor_account,
            'user' => current_user.armor_profile.armor_user,
            'user_name' => current_user.name,
            'user_phone' => current_user.phone
          })
          data.update_company({
            'account' => current_user.armor_profile.armor_account,            
            'company' => current_user.company
          })
          data.update_address({
            'account' => current_user.armor_profile.armor_account,            
            'address' => current_user.location,
            'city' => current_user.city,
            'state' => current_user.state,
            'postal_code' => current_user.zip_code,
            'country' => current_user.country
          })
          data.create_armor_bank_account({
            'account' => current_user.armor_profile.armor_account,            
            'type' => current_user.armor_bank_account.account_type,
            'location' => current_user.armor_bank_account.account_location,
            'bank' => current_user.armor_bank_account.account_bank,
            'routing' => current_user.armor_bank_account.account_routing,
            'swift' => current_user.armor_bank_account.account_swift,
            'account' => current_user.armor_bank_account.account_account,
            'iban' => current_user.armor_bank_account.account_iban
          })
        end
        format.html { redirect_to dashboards_payments_path }
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
	    # (:email, :name, :phone, :company, :location, :facebook, :ein_tax, :asset = [])
	  end
end
