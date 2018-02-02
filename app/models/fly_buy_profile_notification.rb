# == Schema Information
#
# Table name: fly_buy_profile_notifications
#
#  id                               :integer          not null, primary key
#  fly_buy_profile_id               :string
#  invalid_tin                      :boolean          default(FALSE)
#  invalid_ssn                      :boolean          default(FALSE)
#  mfa_pending_tin                  :boolean          default(FALSE)
#  mfa_pending_ssn                  :boolean          default(FALSE)
#
class FlyBuyProfileNotification < ActiveRecord::Base
  belongs_to :fly_buy_profile
end
