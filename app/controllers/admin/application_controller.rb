class Admin::ApplicationController < ApplicationController
  layout 'admin_dashboard'

  before_filter :authenticate_admin!

 private
  def allow_admin_resources
    unless current_admin.is_admin?
      flash[:alert] = 'access denied'
      redirect_to request.referrer
    end
  end
end

