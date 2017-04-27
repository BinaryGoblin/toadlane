desc "order cancelled because the money was not verified 24 hours prior to inspection"
task :order_canceled_fund_not_sent => :environment do
  inspection_dates = InspectionDate.approved.with_order_id.where('inspection_dates.date BETWEEN ? AND ?',
                      Time.now.beginning_of_day,
                      Time.now.end_of_day
                    )

  inspection_dates.each do |inspection_date|
    fly_buy_order = FlyBuyOrder.find_by_id(inspection_date.fly_buy_order_id)
    if fly_buy_order.present? && !fly_buy_order.synapse_transaction_id.present? && !fly_buy_order.cancelled?
      fly_buy_order.update_attribute(:status, 'cancelled')
      order_canceled_fund_not_sent_notification(fly_buy_order, fly_buy_order.buyer)
      order_canceled_fund_not_sent_notification(fly_buy_order, fly_buy_order.seller)
    end
  end
end

private

  def order_canceled_fund_not_sent_notification(order, user)
    UserMailer.order_canceled_fund_not_sent(order, user).deliver_later
    OrderNotifications.new(order, user).order_canceled
  end