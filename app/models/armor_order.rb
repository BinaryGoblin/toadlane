# == Schema Information
#
# Table name: armor_orders
#
#  id                         :integer          not null, primary key
#  buyer_id                   :integer
#  seller_id                  :integer
#  account_id                 :integer
#  product_id                 :integer
#  order_id                   :integer
#  status                     :integer          default(0)
#  unit_price                 :float
#  count                      :integer
#  amount                     :float
#  summary                    :string(100)
#  description                :text
#  invoice_num                :integer
#  purchase_order_num         :integer
#  status_change              :datetime
#  uri                        :string
#  deleted                    :boolean          default(FALSE)
#  created_at                 :datetime
#  updated_at                 :datetime
#  taxes_price                :integer          default(0)
#  rebate_price               :integer          default(0)
#  rebate_percent             :integer          default(0)
#  fee                        :float
#  rebate                     :float
#  shipping_cost              :float
#  inspection_complete        :boolean          default(FALSE)
#  payment_release_url        :string
#  payment_release            :boolean          default(FALSE)
#  funds_in_escrow            :boolean          default(FALSE)
#  seller_charged_fee         :float
#  amount_after_fee_to_seller :float
#

class ArmorOrder < ActiveRecord::Base
  # seller_charged_fee: this fee includes Armor Payments Fee along with Toadlane Fee which is added via Admin-> Fees
  # amount_after_fee_to_seller: the amount(unit_price * count) after deducting seller_charged_fee.
  has_many :inspection_dates, dependent: :destroy
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  has_many :notifications, dependent: :destroy

  scope :with_order_id, -> { where.not(order_id: nil) }

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false)
    .order('created_at DESC')
    .paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: %i{ not_started processing placed failed cancelled}

  def create_armor_api_order(params)
    self.update_attribute(:status, 'processing')
    begin
      client = ArmorService.new
      response = client.orders(seller_account_id).create(params)
      self.update_attribute(:order_id, response.data[:body]["order_id"])
    rescue ArmorService::BadResponseError => e
      self.update_attribute(:status, 'failed')
      Rails.logger.warn e.errors
      return { :error => e }
    else
      self.update_attribute(:status, 'processing')
      product.sold_out += self.count
      self.product.save
      UserMailer.sales_order_notification_to_seller(self).deliver_later
      UserMailer.sales_order_notification_to_buyer(self).deliver_later
      return nil
    end
  end
  # handle_asynchronously :create_armor_api_order

  def seller_account_id
    seller.armor_account_id
  end

  def get_armor_payment_instruction_url
    client = ArmorService.new
    payement_response = client.orders(seller_account_id).paymentinstructions(self.order_id).all
    payement_instruction_uri = payement_response.data[:body]["uri"]
    auth_data =
    { 'uri' => payement_instruction_uri,
    'action' => 'view' }
    response = client.users(buyer.armor_profile.armor_account_id).authentications(buyer.armor_profile.armor_user_id).create(auth_data)
    self.update_attribute(:uri, response.data[:body]["url"])
  end

  def selected_inspection_date
    inspection_dates.approved.first
  end

  def inspection_date_not_marked
    inspection_dates.not_marked_approved.first
  end

  def buyer_requested_inspection_date
    inspection_dates.buyer_added.last.get_inspection_date
  end

  def not_inspected
    inspection_complete == false
  end

end
