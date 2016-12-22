class Users::InvitationsController < Devise::InvitationsController

  # PUT /resource/invitation
  # def update
  #   respond_to do |format|
  #     format.js do
  #       invitation_token = Devise.token_generator.digest(resource_class, :invitation_token, update_resource_params[:invitation_token])
  #       self.resource = resource_class.where(invitation_token: invitation_token).first
  #       resource.skip_password = true
  #       resource.update_attributes update_resource_params.except(:invitation_token)
  #     end
  #     format.html do
  #       super
  #       # resource.update_attributes({terms_of_service: params["user"]["terms_of_service"] == "1" ? true : false, name: params["user"]["name"], terms_accepted_at: DateTime.now})
  #     end
  #   end
  # end

  def update
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    resource.errors.messages.except!(:terms_of_service)
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if Devise.allow_insecure_sign_in_after_accept
        resource.add_role 'user'
        resource.update_attributes({terms_of_service: params["user"]["terms_of_service"] == "1" ? true : false, name: params["user"]["name"], terms_accepted_at: DateTime.now})
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_accept_path_for(resource)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, :location => new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource){ render :edit }
    end
  end
end