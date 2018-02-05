desc 'After a day if funds not received in escrow'
task cancel_transaction_funds_not_received: :environment do
  inspection_dates = InspectionDate.approved.with_order_id.where('inspection_dates.date BETWEEN ? AND ?', 1.days.from_now.beginning_of_day, 1.days.from_now.end_of_day)

  inspection_dates.each do |inspection_date|
    fly_buy_order = FlyBuyOrder.find_by_id(inspection_date.fly_buy_order_id)

    if fly_buy_order.synapse_transaction_id.present? && !fly_buy_order.funds_in_escrow?
      FlyAndBuy::CancelTransaction.new(fly_buy_order.buyer, fly_buy_order).process
    end
  end
end
