class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def stripe_connect
    stripe_profile = current_user.stripe_profile
    stripe_profile = current_user.stripe_profile = StripeProfile.new unless stripe_profile.present?

    omniauth_auth = request.env['omniauth.auth']
    update_params = {
      stripe_uid: omniauth_auth.uid,
      stripe_access_code: omniauth_auth.credentials.token,
      stripe_publishable_key: omniauth_auth.info.stripe_publishable_key
    }

    if stripe_profile.update_attributes(update_params)
      Services::ActivityTracker.track(current_user, stripe_profile)

      set_flash_message(:notice, :success, kind: 'Stripe') if is_navigational_format?
    else
      session['devise.stripe_connect_data'] = omniauth_auth
    end

    redirect_to dashboard_accounts_path
  end
end
