class FinancesMailer < ApplicationMailer

  def multivision_application_email(user, address_id, loan_amount, business_years, monthly_revenue)
    @user = user
    @address = Address.find(address_id)
    @loan_amount = loan_amount
    @business_years = business_years
    @monthly_revenue = monthly_revenue
    mail to: 'johnb@toadlane.com', subject: 'New loan request from Toadlane'
  end
end
