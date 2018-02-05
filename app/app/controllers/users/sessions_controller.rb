class Users::SessionsController < Devise::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]
  before_action :store_location, only: :new

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
  private

  def store_location
    return_to_path = URI(request.referer || '').path
    session[:previous_url] = unless ['/', '/users/sign_in', '/users/sign_up', '/users/password/new', '/users/password/edit', '/users/confirmation', '/users/sign_out'].include?(return_to_path)
      request.referer
    else
      nil
    end
  end
end
