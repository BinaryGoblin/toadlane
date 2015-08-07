class DashboardController < ApplicationController
  layout 'user_dashboard'

  before_filter :authenticate_user!
  before_action :check_terms_of_service
  before_action :check_if_user_active
end
