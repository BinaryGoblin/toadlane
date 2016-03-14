class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def stripe_connect
    @user = current_user
    if @user.stripe_profile.nil?
      @user.stripe_profile = StripeProfile.new
    end
    
    if @user.stripe_profile.update_attributes({
      stripe_uid: request.env["omniauth.auth"].uid,
      stripe_access_code: request.env["omniauth.auth"].credentials.token,
      stripe_publishable_key: request.env["omniauth.auth"].info.stripe_publishable_key
    })
      redirect_to dashboard_accounts_path
      set_flash_message(:notice, :success, :kind => "Stripe") if is_navigational_format?
    else
      session["devise.stripe_connect_data"] = request.env["omniauth.auth"]
      redirect_to dashboard_accounts_path
    end
  end
end