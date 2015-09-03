class FinancesMailer < ActionMailer::Base
  default from: "hello@toadlane.com"

  def multivision_application_email(user, loan_amount, business_years, monthly_revenue)
    @user = user
    @loan_amount = loan_amount
    @business_years = business_years
    @monthly_revenue = monthly_revenue
    mail to: 'johnb@toadlane.com', subject: 'New loan request from Toadlane'
  end
end