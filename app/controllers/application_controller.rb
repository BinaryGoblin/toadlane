class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  def check_terms_of_service
    if current_user.present? && current_user.has_role?(:user)
      if current_user.terms_of_service != true
        redirect_to dashboard_terms_of_services_path
      end
    end
  end

  def after_sign_in_path_for resource

    if current_user.present? && current_user.roles.any?
      if current_user.has_role?(:superadmin) || current_user.has_role?(:admin)
        admin_root_path
      else
        if current_user.terms_of_service != true
          dashboard_terms_of_services_path
        else
          dashboard_profile_path
        end
      end
    else
      super
    end
  end
end
