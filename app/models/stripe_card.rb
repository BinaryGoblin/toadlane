class StripeCard < ActiveRecord::Base
  belongs_to :stripe_customer
end