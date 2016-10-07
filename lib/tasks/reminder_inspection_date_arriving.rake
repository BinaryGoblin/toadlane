desc 'When inspection date is arriving'
task :reminder_inspection_date_arriving => :environment do
  [1, 2].each do |rule|
    approved_inspection_dates = InspectionDate.approved

    inspection_dates = approved_inspection_dates.where('inspection_dates.date BETWEEN ? AND ?',
            rule.days.from_now.beginning_of_day,
            rule.days.from_now.end_of_day
            )

    inspection_dates.each do |inspection_date|
      fly_buy_order = FlyBuyOrder.find_by_id(inspection_date.fly_buy_order_id)
      if fly_buy_order.present? && fly_buy_order.synapse_transaction_id.present?
        UserMailer.send_inspection_date_arriving_to_seller(fly_buy_order, rule).deliver_later
        UserMailer.send_inspection_date_arriving_to_buyer(fly_buy_order, rule).deliver_later
      end
    end
  end
end
