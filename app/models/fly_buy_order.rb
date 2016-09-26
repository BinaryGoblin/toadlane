# == Schema Information
#
# Table name: fly_buy_orders
#
#  id                     :integer          not null, primary key
#  buyer_id               :integer
#  seller_id              :integer
#  product_id             :integer
#  status                 :integer
#  unit_price             :float
#  count                  :integer
#  fee                    :float
#  rebate                 :float
#  rebate_price           :float
#  total                  :float
#  status_change          :datetime
#  deleted                :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  synapse_escrow_node_id :string
#  synapse_transaction_id :string
#

class FlyBuyOrder < ActiveRecord::Base
  has_many :inspection_dates, dependent: :destroy
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product

  def seller_not_mark_approved
    inspection_dates.buyer_added.not_marked_approved.last
  end
end
