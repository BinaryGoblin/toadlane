desc 'When inspection date is arriving'
task :reminder_inspection_date_arriving => :environment do
  promise_pay_instance = PromisePayService.new
  client = promise_pay_instance.client

  [1, 2].each do |rule|
    approved_inspection_dates = InspectionDate.approved

    inspection_dates = approved_inspection_dates.where('inspection_dates.date BETWEEN ? AND ?',
            rule.days.from_now.beginning_of_day,
            rule.days.from_now.end_of_day
            )

    inspection_dates.each do |inspection_date|
      if inspection_date.promise_order.present?
        promise_order = inspection_date.promise_order
        UserMailer.send_inspection_date_arriving_to_seller(promise_order, rule).deliver_later
        UserMailer.send_inspection_date_arriving_to_buyer(promise_order, rule).deliver_later
      end
    end
  end
end
