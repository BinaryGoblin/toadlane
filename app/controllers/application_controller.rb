class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  def after_sign_in_path_for resource

    if current_user.present? && current_user.role.present?
      if current_user.role.name == 'superadmin' || current_user.role.name == 'admin'
        admin_root_path
      else
        dashboards_profile_path
      end
    else
      super
    end
  end
end
