class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  def check_terms_of_service
    if current_user.present? && current_user.has_role?(:user)
      if current_user.terms_of_service != true
        redirect_to terms_of_service_path
      end
    end
  end

  def check_if_user_active
    if current_user.present? && ! (current_user.has_role? :user) && ! (current_user.has_role? :admin)
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
        redirect_path_for_user
      end
    else
      super
    end
  end

  def check_for_mobile
    session[:mobile_override] = params[:mobile] if params[:mobile]
    prepare_for_mobile if mobile_device?
  end

  def mobile_device?
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      (request.user_agent =~ /iPhone|iPod|Android|Mobile|webOS/) && (request.user_agent !~ /iPad/)
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    prepend_view_path Rails.root + 'app' + 'views_mobile'
  end

  private
  def redirect_to_concerned_path
    if current_user.terms_of_service != true
      terms_of_service_path
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
  end

  def redirect_path_for_user
    if current_user.has_role? :user
      if session[:previous_url].present?
        return session[:previous_url]
      else
        redirect_to_concerned_path
      end
    else
      account_deactivated_path
    end
  end
end
