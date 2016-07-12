# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  slug                  :string
#  sku                   :string
#  description           :text
#  start_date            :datetime
#  end_date              :datetime
#  unit_price            :float
#  status                :boolean          default(TRUE)
#  user_id               :integer
#  created_at            :datetime
#  updated_at            :datetime
#  status_action         :string
#  status_characteristic :string
#  amount                :integer
#  sold_out              :integer          default(0), not null
#  dimension_width       :string
#  dimension_height      :string
#  dimension_depth       :string
#  dimension_weight      :string
#  main_category         :integer
#  type                  :integer          default(0)
#

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
