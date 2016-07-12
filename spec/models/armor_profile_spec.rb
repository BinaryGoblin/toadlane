# == Schema Information
#
# Table name: armor_profiles
#
#  id               :integer          not null, primary key
#  armor_account_id :integer
#  armor_user_id    :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

RSpec.describe ArmorProfile do
  let(:user) do
    User.new(
      email: Faker::Internet.safe_email,
      password: Faker::Internet.password,
      name: name,
      phone: phone
    )
  end

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

    context 'with valid armor_profile' do
      before do
        User.skip_callback(:save, :after, :create_armor_profile)
      end

      let(:persisted_user) { user.tap(&:save) }
      let(:profile) do
        profile = persisted_user.build_armor_profile
        profile.save
        profile
      end

      it 'populates armor_account_id and armor_user_id' do
        expect(profile.armor_account_id).to be_present
        expect(profile.armor_user_id).to be_present
      end
    end
  end

end
