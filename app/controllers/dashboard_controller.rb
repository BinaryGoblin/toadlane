class DashboardController < ApplicationController
  layout 'user_dashboard'

  before_filter :authenticate_user!
end