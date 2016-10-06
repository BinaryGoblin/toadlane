# == Schema Information
#
# Table name: inspection_dates
#
#  id               :integer          not null, primary key
#  date             :datetime
#  creator_type     :string
#  product_id       :integer
#  armor_order_id   :integer
#  approved         :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  promise_order_id :integer
#  fly_buy_order_id :integer
#

class InspectionDate < ActiveRecord::Base
  belongs_to :product, class_name: 'Product', foreign_key: 'product_id'
  belongs_to :fly_buy_order, class_name: 'FlyBuyOrder', foreign_key: 'fly_buy_id'

  scope :approved, -> { where(approved: true) }
  scope :rejected, -> { where(approved: false) }
  scope :not_marked_approved, -> { where(approved: nil) }
  scope :seller_added, -> { where(creator_type: "seller") }
  scope :buyer_added, -> { where(creator_type: "buyer") }
  scope :without_order_id, -> { where(promise_order_id: nil) }
  scope :passed_inspection_date, -> { where('date <= ?', DateTime.now) }

  validate :check_inspection_date

  # gives August 09, 2016, 06:00 PM
  def get_inspection_date
    date.strftime("%B %d, %Y, %I:%M %p")
  end

  def check_inspection_date
    if date.present? && product_id.present? && product.default_payment == 'Fly And Buy'
      product = Product.find_by_id(product_id)

      if creator_type == "seller"
        existing_dates_except_self = product.inspection_dates.seller_added
        .where.not(id: id)
        .where('date BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day)
      else
        existing_dates_except_self = product.inspection_dates.where.not(id: id)
        .where('date BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day )
      end

      if existing_dates_except_self.any?
        errors.add(:date, 'must be unique.')
      end

      if date.to_date <= Date.today
        errors.add(:date, 'must be greater than today.')
      end

      if date.to_date < product.end_date.to_date
        errors.add(:date, "must not be greater than product's end date.")
      end
    end
  end
end
