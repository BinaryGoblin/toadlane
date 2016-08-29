class Dashboard::NotificationsController < DashboardController
  def index
    @notifications = Kaminari.paginate_array(current_user.notifications.order('created_at DESC')).page(params[:page]).per(5)

    if current_user.notifications.not_marked_read.present?
      mark_as_read
    end
  end

  private
  def mark_as_read
    current_user.notifications.not_marked_read.each do |notification|
      notification.update_attribute(:read, true)
    end
  end
end
