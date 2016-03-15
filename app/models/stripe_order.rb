class StripeOrder < ActiveRecord::Base
  belongs_to :buyer, :foreign_key => 'buyer_id'
  belongs_to :seller, :foreign_key => 'seller_id'
  belongs_to :product

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false).order('created_at DESC').paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: [ :not_started, :started, :shipping_estimate, :cancelled, :placed, :shipped, :completed, :challenged, :refunded ]
end
