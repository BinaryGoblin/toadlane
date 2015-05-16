class ArmorOrder < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product

  validates_presence_of :unit_price, :account_id

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false)
    .order('created_at DESC')
    .paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: %i{ not_started processing completed failed }

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
