# Preview all emails at http://localhost:3000/rails/mailers/finances_mailer
class FinancesMailerPreview < ActionMailer::Preview
  def multivision_application_email_preview
    FinancesMailer.multivision_application_email(User.first, '$2000', '2 years', '$50,000')
  end
end