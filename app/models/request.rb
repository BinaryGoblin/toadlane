# == Schema Information
#
# Table name: requests
#
#  id           :integer          not null, primary key
#  sender_id    :integer
#  receiver_id  :integer
#  subject      :string
#  body         :text
#  created_at   :datetime
#  updated_at   :datetime
#  conversation :integer
#

class Request < ActiveRecord::Base
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id

  
  validates_presence_of :image_file_name, :image_file_size, :image_content_type
  has_many :request_images, dependent: :destroy
end
