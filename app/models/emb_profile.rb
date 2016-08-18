# == Schema Information
#
# Table name: emb_profiles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  username   :string
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmbProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :username, :password
  validates_uniqueness_of :username
end
