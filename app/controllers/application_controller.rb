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
  
  def check_if_user_active
    if current_user.present? && ! (current_user.has_role? :user)
      redirect_to account_deactivated_path
    end
  end
  
  def get_user_notifications
    notifications = get_user_unread_message_notifications
    # TODO
    # notifications += get_user_new_orders
    
    notifications
  end
  
  def get_user_unread_message_notifications
    unread_receipts ||= current_user.mailbox.receipts.where(is_read: 'false')
    
    if unread_receipts
      unread_receipts.count
    else
      0
    end
  end

  def after_sign_in_path_for resource
    if current_user.present?
      if current_user.has_role?(:superadmin) || current_user.has_role?(:admin)
        admin_root_path
      else
        if current_user.has_role? :user
          if current_user.terms_of_service != true
            dashboard_terms_of_services_path
          else
            if get_user_notifications > 0
              if get_user_unread_message_notifications > 0
                dashboard_messages_path
              else
                # TODO
                # get_user_new_order_notifications
                products_path
              end
            else
              products_path
            end
          end
        else
          account_deactivated_path
        end
      end
    else
      super
    end
  end
end
