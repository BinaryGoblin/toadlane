# == Schema Information
#
# Table name: promise_orders
#
#  id                          :integer          not null, primary key
#  buyer_id                    :integer
#  seller_id                   :integer
#  product_id                  :integer
#  status                      :integer
#  unit_price                  :float
#  count                       :integer
#  fee                         :float
#  rebate                      :float
#  rebate_price                :float
#  amount                      :float
#  status_change               :datetime
#  deleted                     :boolean          default(FALSE)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  promise_item_id             :string
#  inspection_complete         :boolean          default(FALSE)
#  funds_in_escrow             :boolean          default(FALSE)
#  seller_charged_fee          :float
#  amount_after_fee_to_seller  :float
#  payment_release             :boolean          default(FALSE)
#  refunded                    :boolean          default(FALSE)
#  ach_fee_amount              :float
#  transaction_fee_amount      :float
#  fraud_protection_fee_amount :float
#  end_user_support_fee_amount :float
#

class PromiseOrder < ActiveRecord::Base
  has_many :inspection_dates, dependent: :destroy
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  has_many :notifications, dependent: :destroy

  TestPromiseSellerFeeID = {
    ach_fee: '057ad7cd-8958-45f8-9584-8ae89406ca9b',
    transaction_fee: '2008604d-b965-4186-8d06-1eed4584c106',
    end_user_fee: 'c22d63cc-797e-49fc-a7e9-2255062e048f'
  }

  # TODO: need to add this when sending to production
  ProductionPromiseSellerFeeID = {}

  scope :with_promise_item_id, -> { where.not(promise_item_id: nil) }

  scope :not_deleted, -> { where.not(deleted: true) }

  attr_accessor :bank_name, :account_name, :routing_number, :account_number,
                  :account_type, :holder_type, :country, :direct_debit_agreement

  enum status: %i{ payment_required completed cancelled failed payment_pending payment_deposited payment_held work_completed refunded}

  def selected_inspection_date
    inspection_dates.approved.last
  end

  def promise_seller_fee_id
    if Rails.env.production?
      fee = ProductionPromiseSellerFeeID
    else
      fee = TestPromiseSellerFeeID
    end
  end

  def not_inspected
    inspection_complete == false
  end

  def inspection_date_today?
    if selected_inspection_date.present? && selected_inspection_date.date.present?
      selected_inspection_date.date.to_date == Date.today
    end
  end

  def buyer_requested_inspection_date
    inspection_dates.buyer_added.last.get_inspection_date
  end

  def seller_not_mark_approved
    inspection_dates.buyer_added.not_marked_approved.last
  end

  def buyer_bank_id
    buyer.promise_account.bank_account_id
  end
end
