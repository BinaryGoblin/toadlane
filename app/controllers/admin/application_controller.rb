class Admin::ApplicationController < ApplicationController
  layout 'admin_dashboard'

  before_filter :authenticate_user!
  before_filter :allow_admin_resources
  before_action :check_terms_of_service

  private
    def allow_admin_resources
      unless current_user.has_role?(:admin) or current_user.has_role?(:superadmin)
        flash[:alert] = 'access denied'
        redirect_to root_path
      end
    end
end

