class ApplicationController < ActionController::Base
  include InspectionServiceHelper

  before_filter :authenticate
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  helper_method :inspected_items_count

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
    sign_in_url = new_user_session_url
    if current_user.present?
      if request.referer == sign_in_url
        super
      else
        if current_user.has_role?(:superadmin) || current_user.has_role?(:admin)
          admin_root_path
        else
          stored_location_for(resource) || request.referer || root_path
        end
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

  protected

  def generate_encrypted_fingerprint(fingerprint)
    "user_#{current_user.id}_#{fingerprint}"
  end

  private

  def redirect_to_concerned_path(resource)
    if !resource.i_buy_and_sell_present?
      products_path(i_buy_and_sell: false)
    else
      products_path
    end
  end

  def redirect_path_for_user(resource)
    if resource.has_role? :user
      if session[:previous_url].present?
        previous_visited_url = session[:previous_url]
        session.delete(:previous_url)
        return previous_visited_url
      else
        redirect_to_concerned_path(resource)
      end
    else
      account_deactivated_path
    end
  end

  def authenticate
    unless Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == "toadlane" && password == "mantoad333"
      end
    end
  end
end
