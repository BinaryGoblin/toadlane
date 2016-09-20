# == Schema Information
#
# Table name: fly_buy_profiles
#
#  id              :integer          not null, primary key
#  synapse_user_id :string
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class FlyBuyProfile < ActiveRecord::Base
  belongs_to :user
end
