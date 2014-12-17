require 'spec_helper'

describe Pricebreak do
  let(:pricebreak) { FactoryGirl.create(:pricebreak) }

  it 'has a valid factory' do
    expect(pricebreak).to be_valid
  end

  describe 'associations' do
   it { should belong_to(:product) }
  end

  describe 'validates' do
    context 'presence' do
      %i[min_count max_count money needs product_id].each do |field|
        it { should validate_presence_of field }
      end
    end

    context 'numericality' do
      %i[min_count max_count money needs product_id].each do |field|
        it { should validate_numericality_of field }
      end
    end
  end

  describe 'fields' do
    it { should have_db_column(:min_count).of_type(:integer) }
    it { should have_db_column(:max_count).of_type(:integer) }
    it { should have_db_column(:money).of_type(:float) }
    it { should have_db_column(:needs).of_type(:integer) }
    it { should have_db_column(:product_id).of_type(:integer) }
  end
end

