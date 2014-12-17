class ArmorInvoice < ActiveRecord::Base
  belongs_to :user, class_name: 'Buyer', foreign_key: 'buyer_id'
  belongs_to :user, class_name: 'Seller', foreign_key: 'seller_id'
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :product

  def self.own_invoices(id)
    ArmorInvoice.where("user_id = ?", id)
  end
end
