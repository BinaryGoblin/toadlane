class ArmorOrder < ActiveRecord::Base
  belongs_to :user, class_name: 'Buyer', foreign_key: 'buyer_id'
  belongs_to :user, class_name: 'Seller', foreign_key: 'seller_id'
  belongs_to :product

  validates_presence_of :unit_price, :account_id

  default_scope { where.not(unit_price: nil, account_id: nil) }

  def self.own_orders(id)
    armor_user = User.find(id).armor_profile.armor_user if id.present?
    ArmorOrder.where("buyer_id = ? or seller_id = ?", armor_user, armor_user )
  end

  def self.orders_for_sell(id)
    armor_user = User.find(id).armor_profile.armor_user if id.present?
    ArmorOrder.where("buyer_id = ?", armor_user )
  end

  def self.orders_for_buy(id)
    armor_user = User.find(id).armor_profile.armor_user if id.present?
    ArmorOrder.where("seller_id = ?", armor_user )
  end
end
