# == Schema Information
#
# Table name: green_profiles
#
#  id                 :integer          not null, primary key
#  green_client_id    :string
#  green_api_password :string
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class GreenProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :green_client_id, :green_api_password
  validates_uniqueness_of :green_client_id
end
