require 'spec_helper'

describe ArmorProfile do
  let(:user) { User.new(email: Faker::Internet.safe_email, password: Faker::Internet.password, name: name, phone: phone) }

  context 'without user name and phone' do
    let(:name) { nil }
    let(:phone) { nil }
    it 'does not create an ArmorProfile' do
      expect { user.save }.to_not change { ArmorProfile.count }
    end
  end

  context 'user with name and phone' do
    let(:name) { Faker::Name.name }
    let(:phone) { '1112223333' }
    it 'does create an ArmorProfile' do
      expect { user.save }.to change { ArmorProfile.count }
    end
  end
end