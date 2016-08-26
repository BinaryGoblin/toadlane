class Dashboard::NotificationsController < DashboardController
  def index
    @notifications = current_user.notifications.order('created_at DESC')
    mark_as_read
  end

  private
  def mark_as_read
    current_user.notifications.each do |notification|
      notification.update_attribute(:read, true)
    end
  end
end
