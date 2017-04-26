# == Schema Information
#
# Table name: fly_buy_orders
#
#  id                                   :integer          not null, primary key
#  buyer_id                             :integer
#  seller_id                            :integer
#  product_id                           :integer
#  status                               :integer
#  unit_price                           :float
#  count                                :integer
#  fee                                  :float
#  rebate                               :float
#  rebate_price                         :float
#  total                                :float
#  status_change                        :datetime
#  deleted                              :boolean          default(FALSE)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  synapse_escrow_node_id               :string
#  synapse_transaction_id               :string
#  inspection_complete                  :boolean          default(FALSE)
#  payment_release                      :boolean          default(FALSE)
#  funds_in_escrow                      :boolean          default(FALSE)
#  seller_fees_percent                  :float
#  seller_fees_amount                   :float
#  group_seller_id                      :integer
#  group_seller                         :boolean          default(FALSE)
#  payment_released_to_group            :boolean          default(FALSE)
#  fly_buy_fee                          :float
#  error_details                        :json
#  percentage_of_inspection_service     :integer
#  inspection_service_cost              :float
#  inspection_service_comment           :text
#

class FlyBuyOrder < ActiveRecord::Base
  #
  ## group_seller => If the product has additional seller i.e group then this field is true else false
  ## group_id => If the product has additional seller i.e. group, then this filed represents the group id
  ### if the group_seller is true, then then the `seller_id` field will be the id of the product owner
  ####  i.e the initial seller who creates group and adds the other additional sellers

  has_many :inspection_dates, dependent: :destroy
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :seller_group, class_name: 'Group', foreign_key: 'group_seller_id'
  belongs_to :product
  has_many :additional_seller_fee_transactions, dependent: :destroy

  scope :with_transaction_id, -> { where.not(synapse_transaction_id: nil) }
  scope :not_deleted, -> { where.not(deleted: true) }

  # If the transaction is created in synapsepay, the status should be "Pending Confirmation",
  #  This is assuming the money has not been wired into escrow.
  ## if the money has been wired into the escrow the status of the order would be
  ##  “Pending Inspection”, and on the date of inspection the status changes to
  ###  “Pending Fund Release”, and then the final status should be “Completed”.

  enum status: [:cancelled, :placed, :completed, :refunded,
                :processing, :pending_confirmation, :pending_inspection, :pending_fund_release,
                :processing_fund_release, :queued, :processing_fund_release_to_group,
                :payment_released_to_group]

  RELEASE_PAYMENT_STATE = ['processing_fund_release', 'processing_fund_release_to_group', 'payment_released_to_group'].freeze

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

  def order_a_million?
    total >= 1000000
  end

  def get_toadlane_fee
    Fee.find_by(module_name: 'Fly & Buy').value
  end

  def additional_sellers_account_created_verified?
    product.additional_sellers.each do |add_seller|
      return !add_seller.fly_buy_profile.present? || !add_seller.fly_buy_profile_account_added? || add_seller.fly_buy_unverified_by_admin?
    end
  end

  def self.pending_orders
    all - completed - refunded
  end

  def total_earning
    get_toadlane_fee.present? ? total - get_toadlane_fee - fee : total - fee
  end

  def total_price
    unit_prices = (count.to_f * unit_price.to_f)
    
    unit_prices + get_toadlane_fee.to_f + fly_buy_fee.to_f + shipping_cost.to_f - (unit_prices * rebate.to_f / 100)
  end

  def amount_pay_to_seller
    total.to_f - total_fees - amount_pay_to_group_seller
  end

  def amount_pay_to_group_seller
    sum = 0
    seller_group.group_sellers.each do |group_member|
      sum += calulate_individual_seller_fee(group_member.fee)
    end if seller_group.present?
    sum
  end

  def total_fees
    fee.to_f + fly_buy_fee.to_f + inspection_service_cost.to_f
  end

  def toadlane_earning
    total_fees - (additional_seller_fee_transactions.count * 2) - 0.05
  end

  def create_additional_seller_fee_transactions
    seller_group.group_sellers.each do |group_seller|
      additional_seller_fee_transaction = additional_seller_fee_transactions.where(user_id: group_seller.user_id).first
      fee = calulate_individual_seller_fee(group_seller.fee)

      unless fee.zero?
        if additional_seller_fee_transaction.present?
          additional_seller_fee_transaction.update_attribute(:fee, fee)
        else
          additional_seller_fee_transactions.create(
            user_id: group_seller.user_id,
            group_id: group_seller.group_id,
            fee: fee
          )
        end
      end
    end if seller_group.present?
  end

  def calulate_individual_seller_fee(per_unit_commission)
    count * per_unit_commission.to_f
  end
end
