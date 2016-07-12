# == Schema Information
#
# Table name: pricebreaks
#
#  id         :integer          not null, primary key
#  quantity   :integer
#  price      :float
#  product_id :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :pricebreak do
    min_count 1
    max_count 10
    money 100
    needs 1

    association :product
  end
end
