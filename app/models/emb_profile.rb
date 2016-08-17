class EmbProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :username, :password
  validates_uniqueness_of :username
end
