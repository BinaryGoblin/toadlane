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
#  inspection_complete    :boolean          default(FALSE)
#  payment_release        :boolean          default(FALSE)
#  funds_in_escrow        :boolean          default(FALSE)
#  seller_fees_percent    :float
#  seller_fees_amount     :float
#

class FlyBuyOrder < ActiveRecord::Base
  has_many :inspection_dates, dependent: :destroy
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product

  scope :with_transaction_id, -> { where.not(synapse_transaction_id: nil) }
  scope :not_deleted, -> { where.not(deleted: true) }

  # If the transaction is created in synapsepay, the status should be "Pending Confirmation",
  #  This is assuming the money has not been wired into escrow.
  ## if the money has been wired into the escrow the status of the order would be
  ##  “Pending Inspection”, and on the date of inspection the status changes to
  ###  “Pending Fund Release”, and then the final status should be “Placed”.

  enum status: [ :cancelled, :placed, :completed, :refunded,
                :processing, :pending_confirmation, :pending_inspection, :pending_fund_release ]

  def seller_not_mark_approved
    inspection_dates.buyer_added.not_marked_approved.last
  end

  def not_inspected
    inspection_complete == false
  end

  def inspection_date_today?
    if selected_inspection_date.present? && selected_inspection_date.date.present?
      selected_inspection_date.date.to_date == Date.today
    end
  end

  def selected_inspection_date
    inspection_dates.approved.first
  end

  def buyer_requested
    inspection_dates.buyer_added.last
  end

  def buyer_requested_inspection_date
    buyer_requested.get_inspection_date
  end

  def inspection_date_rejected_by_seller
    inspection_dates.buyer_added.rejected
  end

  def inspected
    !not_inspected
  end
end
