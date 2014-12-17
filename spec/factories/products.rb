FactoryGirl.define do
  factory :product do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    start_date Time.now - 1.year
    end_date Time.now + 1.year
    unit_price 100
    tax_level 12
    status true

    association :user
  end
end
