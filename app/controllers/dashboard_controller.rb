class DashboardController < ApplicationController
  layout 'user_dashboard'

  before_filter :authenticate_user!
  before_action :check_terms_of_service
  before_action :check_if_user_active

  protected

  def expected_group_members(user)
    @expected_group_members = User.ordered_by_name.select {|u| u.id != user.id }
  end
end
