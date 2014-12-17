require 'spec_helper'

describe Image do
  let(:image) { FactoryGirl.create(:image) }

  it 'has a valid factory' do
    expect(image).to be_valid
  end

  describe 'associations' do
    it { should belong_to(:product) }
  end

  describe 'validates' do
    context 'presence' do
      %i[product_id image_file_name image_file_size image_content_type].each do |field|
        it { should validate_presence_of field }
      end
    end
  end

  describe 'fields' do
    it { should have_db_column(:product_id).of_type(:integer) }
    it { should have_db_column(:image_file_name).of_type(:string) }
    it { should have_db_column(:image_file_size).of_type(:string) }
    it { should have_db_column(:image_content_type).of_type(:string) }
  end
end

