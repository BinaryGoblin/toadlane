# == Schema Information
#
# Table name: stripe_cards
#
#  id                 :integer          not null, primary key
#  stripe_customer_id :integer
#  stripe_card_id     :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class StripeCard < ActiveRecord::Base
  belongs_to :stripe_customer
end
