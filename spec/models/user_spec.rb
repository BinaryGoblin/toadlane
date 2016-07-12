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

require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  describe 'associations' do
   it { should have_many(:products) }
  end

  describe 'fields' do
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:phone).of_type(:string) }
    it { should have_db_column(:company).of_type(:string) }
    it { should have_db_column(:address).of_type(:string) }
    it { should have_db_column(:facebook).of_type(:string) }
    it { should have_db_column(:ein_tax).of_type(:string) }
    it { should have_db_column(:receive_private_info).of_type(:boolean) }
    it { should have_db_column(:receive_new_offer).of_type(:boolean) }
    it { should have_db_column(:receive_tips).of_type(:boolean) }
  end
end

