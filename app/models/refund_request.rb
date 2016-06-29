class RefundRequest < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :green_order

  validates_uniqueness_of :green_order_id

  # requested must be first (ie. at index 0) for the default value to be correct
  enum status: [ :requested, :accepted, :rejected ]
end
