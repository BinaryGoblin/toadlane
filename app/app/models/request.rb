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
end
