# == Schema Information
#
# Table name: promise_orders
#
#  id            :integer          not null, primary key
#  buyer_id      :integer
#  seller_id     :integer
#  product_id    :integer
#  status        :integer
#  unit_price    :float
#  count         :integer
#  fee           :float
#  rebate        :float
#  rebate_price  :float
#  amount        :float
#  status_change :datetime
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PromiseOrder < ActiveRecord::Base
  has_many :inspection_dates, dependent: :destroy
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  has_many :notifications, dependent: :destroy
end
