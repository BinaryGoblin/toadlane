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

      it 'populates armor_account and armor_user' do
        expect(profile.armor_account).to be_present
        expect(profile.armor_user).to be_present
      end
    end
  end

end