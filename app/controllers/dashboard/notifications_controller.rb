class Dashboard::NotificationsController < DashboardController
  def index
    @notifications = current_user.notifications.not_deleted.order('created_at DESC')

    if current_user.notifications.not_deleted.not_marked_read.present?
      mark_as_read
    end
  end

  def delete_cascade
    if params[:notification_ids].present?
      params[:notification_ids].each do |id|
        Notification.find(id).update(deleted: true)
      end
    end

    render json: :ok
  end

  private
  def mark_as_read
    current_user.notifications.not_deleted.not_marked_read.each do |notification|
      notification.update_attribute(:read, true)
    end
  end
end
