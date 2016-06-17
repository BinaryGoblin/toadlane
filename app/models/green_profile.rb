class GreenProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :green_client_id, :green_api_password
end
