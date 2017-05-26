# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every :day, :at => '12:01am' do
  rake "reminder_inspection_date_arriving"
  rake "on_inspection_date_order_status_change"
  rake "email_notification_buyer_send_funds"
  rake "cancel_transaction_funds_not_received"
  rake "product_expired_notification"
  # rake "order_canceled_fund_not_sent"
end
