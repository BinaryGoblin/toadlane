# == Schema Information
#
# Table name: refund_requests
#
#  id             :integer          not null, primary key
#  green_order_id :integer
#  buyer_id       :integer
#  seller_id      :integer
#  status         :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted        :boolean          default(FALSE)
#

class RefundRequest < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :green_order

  validates_uniqueness_of :green_order_id, :allow_blank => true, :allow_nil => true

  # TODO: the order could be of other types later
  delegate :product, :total, :count, :unit_price, to: :green_order

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false).order('created_at DESC').paginate(page: page, per_page: per_page)
  end

  # requested must be first (ie. at index 0) for the default value to be correct
  enum status: [ :requested, :accepted, :rejected ]

  def acceptable?(user_id)
    self.seller_id == user_id
  end

  def refund
    green_profile = seller.try(:green_profile)
    if seller.present? && green_profile.present?
      green_service = GreenService.new(
        green_profile.green_client_id,
        green_profile.green_api_password
      )
      green_service.refund_check(refund_params)
    else
      {
        "Result" => "404",
        "ResultDescription" => "Seller not found or invalid Green Profile",
        "RefundCheckNumber" => "",
        "RefundCheck_ID" => ""
      }
    end
  end

  private

  def refund_params
    params = {
      "Check_ID" => "#{green_order.check_id}",
      "RefundMemo" => "p:#{product.id}u:#{buyer.id}",
      "RefundAmount" => "#{total}"
    }
  end
end
