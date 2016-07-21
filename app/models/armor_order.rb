# == Schema Information
#
# Table name: armor_orders
#
#  id                 :integer          not null, primary key
#  buyer_id           :integer
#  seller_id          :integer
#  account_id         :integer
#  product_id         :integer
#  order_id           :integer
#  status             :integer          default(0)
#  unit_price         :float
#  count              :integer
#  amount             :float
#  summary            :string(100)
#  description        :text
#  invoice_num        :integer
#  purchase_order_num :integer
#  status_change      :datetime
#  uri                :string
#  deleted            :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  taxes_price        :integer          default(0)
#  rebate_price       :integer          default(0)
#  rebate_percent     :integer          default(0)
#

class ArmorOrder < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product

  # validates_presence_of :unit_price, :account_id

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
      response = client.orders(account_id).create(params)
      self.update_attribute(:order_id, response.data[:body]["order_id"])
    rescue ArmorService::BadResponseError => e
      self.update_attribute(:status, 'failed')
      Rails.logger.warn e.errors
    else
      self.update_attribute(:status, 'completed')
    end
  end
  handle_asynchronously :create_armor_api_order
end
