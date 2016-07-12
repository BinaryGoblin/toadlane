# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  parent_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Category do
  let(:category) { FactoryGirl.create(:category) }

  it 'has a valid factory' do
    expect(category).to be_valid
  end

  describe 'associations' do
   it { should have_many(:products) }
   it { should have_many(:subcategories) }       
   it { should belong_to(:parent_category) }       
  end

  describe 'validations' do
    it { should validate_presence_of :name }
  end

  describe 'fields' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:parent_id).of_type(:integer) }
  end 
end

