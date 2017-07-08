desc "On the date of inspection change the orders status"
task :on_inspection_date_order_status_change => :environment do
  approved_inspection_dates = InspectionDate.approved

  inspection_dates = approved_inspection_dates.where('inspection_dates.date BETWEEN ? AND ?',
                        DateTime.now.beginning_of_day,
                        DateTime.now.end_of_day
                      )

  inspection_dates.each do |inspection_date|
    fly_buy_order = FlyBuyOrder.find_by_id(inspection_date.fly_buy_order_id)
    if fly_buy_order.present? && fly_buy_order.synapse_transaction_id.present? && fly_buy_order.funds_in_escrow?
      fly_buy_order.update_attribute(:status, 'pending_fund_release')
    end
  end
end
