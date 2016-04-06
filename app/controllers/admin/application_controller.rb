class Admin::ApplicationController < ApplicationController
  layout 'admin_dashboard'

  before_filter :authenticate_admin!
  before_action :check_if_user_active
  before_action :check_terms_of_service

  private
    def allow_admin_resources
      unless current_user.is_admin?
        flash[:alert] = 'access denied'
        redirect_to request.referrer
      end
    end
end

