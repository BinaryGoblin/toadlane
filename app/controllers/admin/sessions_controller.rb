class Admin::SessionsController < Devise::SessionsController
  layout 'admin_dashboard'

  skip_before_filter :require_no_authentication, only: [:new, :create]

  private
    def after_sign_in_path_for(resource_or_scope)
      admin_categories_path
    end

    def redirect_logged_in_user
      admin_categories_path
    end
end

