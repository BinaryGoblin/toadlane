# == Schema Information
#
# Table name: stripe_profiles
#
#  id                     :integer          not null, primary key
#  stripe_publishable_key :string
#  stripe_uid             :string
#  stripe_access_code     :string
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class StripeProfile < ActiveRecord::Base
  belongs_to :user
end
