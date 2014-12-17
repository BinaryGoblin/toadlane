FactoryGirl.define do
  factory :pricebreak do
    min_count 1
    max_count 10
    money 100
    needs 1

    association :product
  end
end
