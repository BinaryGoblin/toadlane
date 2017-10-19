class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def create
    super
    if @user.persisted?
      @user.add_role 'user'
      flash[:notice] = 'Your account was successfully created! You will receive an email with instructions about how to confirm your account in a few minutes. If you don\'t receive it, be sure to add hello@toadlane.com to your list of contacts and check your spam folder, as our messages can sometimes get caught up in automated spam filters.'
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:terms_of_service, :terms_accepted_at, :Synapsetos, :email, :name, :password, :password_confirmation, { tag_list: []}]
  end
end
