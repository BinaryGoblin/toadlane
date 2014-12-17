FactoryGirl.define do
  factory :user do
    email Faker::Internet.email
    password 'password'
    password_confirmation 'password'
    # name
    # phone
    # company
    # location
    # facebook
    # ein_tax
  end
end
