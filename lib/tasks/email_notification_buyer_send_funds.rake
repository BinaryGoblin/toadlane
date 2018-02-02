desc "Reminder to send funds into escrow"
task :email_notification_buyer_send_funds => :environment do
  fly_buy_orders = FlyBuyOrder.not_deleted.pending_confirmation.where('created_at BETWEEN ? AND ?',
                      1.day.ago.beginning_of_day,
                      1.day.ago.now.end_of_day
                    )

  fly_buy_orders.each do |fly_buy_orders|
    UserMailer.send_wire_instruction_notification_to_buyer(fly_buy_order).deliver_later
  end
end