require 'spec_helper'

describe Product do
  let(:product) { FactoryGirl.create(:product) }

  it 'has a valid factory' do
    expect(product).to be_valid
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:categories) }
    it { should have_many(:images) }
  end

  describe 'validates' do
    context 'presence' do
      %i[name user_id start_date end_date].each do |field|
        it { should validate_presence_of field }
      end
    end

    context 'numericality' do
      it { should validate_numericality_of :unit_price }
     end
  end

  describe 'fields' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:start_date).of_type(:datetime) }
    it { should have_db_column(:end_date).of_type(:datetime) }
    it { should have_db_column(:unit_price).of_type(:float) }
    it { should have_db_column(:tax_level).of_type(:string) }
    it { should have_db_column(:status).of_type(:boolean) }
    it { should have_db_column(:user_id).of_type(:integer) }
  end
  
  describe 'images data' do
   it{ should accept_nested_attributes_for :images }
  end
end

