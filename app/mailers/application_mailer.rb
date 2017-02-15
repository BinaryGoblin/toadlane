class ApplicationMailer < ActionMailer::Base
  include SendGrid

  default from: "Toadlane Notifications hello@toadlane.com"
end
