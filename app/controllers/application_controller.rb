class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  def after_sign_in_path_for resource

    if current_user.present? && current_user.roles.any?
      if current_user.has_role?(:superadmin) || current_user.has_role?(:admin)
        admin_root_path
      else
        dashboard_profile_path
      end
    else
      super
    end
  end
end
