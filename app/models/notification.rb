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
#  deleted         :boolean          default(FALSE)
#

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :armor_order
  belongs_to :amg_order
  belongs_to :emb_order
  belongs_to :stripe_order
  belongs_to :green_order

  scope :not_marked_read, -> { where(read: false) }
  scope :not_deleted, -> { where(deleted: false) }
end
