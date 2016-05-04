class RegistrationsController < Devise::RegistrationsController  
  def create
    build_resource(sign_up_params)

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if params[:type_of_account] == 'user'
        resource.add_role 'user'

        raw, enc = Devise.token_generator.generate(resource.class, :confirmation_token)
        resource.confirmation_token = enc
        resource.confirmed_at = nil
        resource.save
        UserMailer.event_notification_user(user, raw).deliver

      elsif params[:type_of_account] == 'admin'
        resource.add_role 'admin'

        raw, enc = Devise.token_generator.generate(resource.class, :confirmation_token)
        resource.confirmation_token = enc
        resource.confirmed_at = nil
        resource.save
        UserMailer.event_notification_admin(user, raw).deliver
      else
        resource.add_role 'user'
      end

      redirect_to root_path, notice: 'Your account was successfully created! You will receive an email with instructions about how to confirm your account in a few minutes. If you don\'t receive it, be sure to add hello@toadlane.com to your list of contacts and check your spam folder, as our messages can sometimes get caught up in automated spam filters.'
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      respond_with resource
    end
  end

  private
    def user_params
      params.fetch(:user, {}).permit(:email, :name, :password, :password_confirmation, :company, :address, :phone)
    end

    def sign_up_params
      params.require(:user).permit(:terms_of_service, :terms_accepted_at, :email, :password, :password_confirmation)
    end
end
