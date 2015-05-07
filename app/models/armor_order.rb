class ArmorOrder < ActiveRecord::Base
  belongs_to :user, class_name: 'Buyer', foreign_key: 'buyer_id'
  belongs_to :user, class_name: 'Seller', foreign_key: 'seller_id'
  belongs_to :product

  validates_presence_of :unit_price, :account_id

  default_scope { where.not(unit_price: nil, account_id: nil) }

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: %i{ not_started processing completed failed }

  def self.own_orders(id)
    armor_user = User.find(id).armor_user_id if id.present?
    ArmorOrder.where("buyer_id = ? or seller_id = ?", armor_user, armor_user )
  end

  def self.orders_for_sell(id)
    armor_user = User.find(id).armor_user_id if id.present?
    ArmorOrder.where("buyer_id = ?", armor_user )
  end

  def self.orders_for_buy(id)
    armor_user = User.find(id).armor_user_id if id.present?
    ArmorOrder.where("seller_id = ?", armor_user )
  end

  def create_armor_api_order(account_id, params)
    self.update_attribute(:status, 'processing')
    begin
      client = ArmorService.new
      client.orders(account_id).create(params)
    rescue ArmorService::BadResponseError => e
      self.update_attribute(:status, 'failed')
      Rails.logger.warn e.errors
    else
      self.update_attribute(:status, 'completed')
    end
  end
  handle_asynchronously :create_armor_api_order
end
