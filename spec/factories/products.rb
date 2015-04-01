FactoryGirl.define do
  factory :product do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    start_date Time.now - 1.year
    end_date Time.now + 1.year
    unit_price 100
    status true
    amount 100

    association :user
  end
end
