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
    it { should have_db_column(:location).of_type(:string) }
    it { should have_db_column(:facebook).of_type(:string) }
    it { should have_db_column(:ein_tax).of_type(:string) }
    it { should have_db_column(:receive_private_info).of_type(:boolean) }
    it { should have_db_column(:receive_new_offer).of_type(:boolean) }
    it { should have_db_column(:receive_tips).of_type(:boolean) }
  end
end

