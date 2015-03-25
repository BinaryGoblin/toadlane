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
        unless current_user.armor_profile.present?
          if current_user.name.present? && current_user.email.present? && current_user.phone.present?
            data = ArmorService.new

            account = data.create_account({
              'company' => current_user.company, 
              'user_name' => current_user.name, 
              'user_email' => current_user.email, 
              'user_phone' => current_user.phone
            })

            if account.present?
              profile = ArmorProfile.create(user_id: current_user.id, armor_account: account.to_i)
              profile.update(armor_user: data.get_user(account).to_i)
            end
          end
        end

        dashboards_profile_path
      end
    else
      super
    end
  end
end
