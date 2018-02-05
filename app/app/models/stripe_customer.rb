# == Schema Information
#
# Table name: stripe_customers
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  stripe_customer_id :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class StripeCustomer < ActiveRecord::Base
  belongs_to :user
  has_many :stripe_cards
end
