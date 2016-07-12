# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  phone                  :string
#  company                :string
#  facebook               :string
#  ein_tax                :string
#  receive_private_info   :boolean          default(TRUE)
#  receive_new_offer      :boolean          default(TRUE)
#  receive_tips           :boolean          default(TRUE)
#  asset_file_name        :string
#  asset_file_size        :string
#  asset_content_type     :string
#  created_at             :datetime
#  updated_at             :datetime
#  benefits               :text
#  is_reseller            :boolean          default(FALSE)
#  armor_account_id       :integer
#  armor_user_id          :integer
#  terms_of_service       :boolean
#  terms_accepted_at      :datetime
#

FactoryGirl.define do
  factory :user do
    email Faker::Internet.email
    password 'password'
    password_confirmation 'password'
  end
end
