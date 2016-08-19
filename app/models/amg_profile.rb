# == Schema Information
#
# Table name: amg_profiles
#
#  id          :integer          not null, primary key
#  amg_api_key :string
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  username    :string
#  password    :string
#

class AmgProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :username, :password
  validates_uniqueness_of :username
end
