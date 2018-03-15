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

  has_attached_file :image, styles: {
                                small: '110x95#',
                                medium: '240x225#',
                                big: '620x420#'
                              },
                              default_url: '/images/products/:style/missing.png'
  do_not_validate_attachment_file_type :image
end
