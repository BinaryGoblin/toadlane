# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  armor_order_id  :integer
#  title           :string
#  read            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  amg_order_id    :integer
#  emb_order_id    :integer
#  stripe_order_id :integer
#  green_order_id  :integer
#

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :armor_order
end
