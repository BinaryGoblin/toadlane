# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  slug                  :string
#  sku                   :string
#  description           :text
#  start_date            :datetime
#  end_date              :datetime
#  unit_price            :float
#  status                :boolean          default(TRUE)
#  user_id               :integer
#  created_at            :datetime
#  updated_at            :datetime
#  status_action         :string
#  status_characteristic :string
#  amount                :integer
#  sold_out              :integer          default(0), not null
#  dimension_width       :string
#  dimension_height      :string
#  dimension_depth       :string
#  dimension_weight      :string
#  main_category         :integer
#  type                  :integer          default(0)
#  views_count           :integer          default(0)
#  deleted_at            :datetime
#  negotiable            :boolean
#  default_payment       :string
#  minimum_order_quantity :integer         default(0)
#  model                 :string
#  brand                 :string
#  condition             :string
#  folder_id             :integer
#

class Product < ActiveRecord::Base
  include AdditionalSeller
  acts_as_commontable
  acts_as_paranoid
  is_impressionable :counter_cache => true, :column_name => :views_count, :unique => :session_hash
  acts_as_taggable

  PaymentOptions = {
    green: 'Echeck',
    stripe: 'Stripe',
    amg: 'Credit Card',
    emb: 'Credit Card (EMB)',
    fly_buy: 'Fly And Buy',
    same_day: 'Same Day Pay'
  }

  has_many :notifications, :as => :notifiable, dependent: :destroy

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  self.inheritance_column = nil # So that the :type enum doesn't complain about Single Table Inheritance
  enum type: [ :on_sale, :in_demand ]

  has_paper_trail

  has_many :stripe_orders, dependent: :destroy
  has_many :green_orders, dependent: :destroy
  has_many :armor_orders, dependent: :destroy
  has_many :amg_orders, dependent: :destroy
  has_many :emb_orders, dependent: :destroy
  has_many :fly_buy_orders, dependent: :destroy
  has_many :product_categories, autosave: true, dependent: :destroy
  has_many :categories, through: :product_categories, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :pricebreaks, -> { order(quantity: :asc) }, autosave: true, dependent: :destroy
  has_many :shipping_estimates, dependent: :destroy
  has_many :certificates, dependent: :destroy
  has_many :inspection_dates, dependent: :destroy
  has_one :group, dependent: :destroy
  belongs_to :folder
  has_many :activities, class_name: 'Task', as: :taskable, dependent: :destroy

  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :certificates, allow_destroy: true
  accepts_nested_attributes_for :videos, allow_destroy: true
  accepts_nested_attributes_for :group, allow_destroy: true, reject_if: ->(attributes) { attributes[:name].blank? }
  accepts_nested_attributes_for :shipping_estimates, :allow_destroy => true, reject_if: -> (estimate) { (estimate[:cost].blank? && estimate[:description].blank?) }

  accepts_nested_attributes_for :inspection_dates, allow_destroy: true, reject_if: ->(attributes) { attributes[:date].blank? }
  belongs_to :category, class_name: "Category", foreign_key: :main_category

  accepts_nested_attributes_for :product_categories
  accepts_nested_attributes_for :pricebreaks, allow_destroy: true, :reject_if => :all_blank

  validates_numericality_of :unit_price, :amount, only_integer: false, greater_than: 0, less_than: 1000000
  validates :end_date, :status_characteristic, :name, :tag_list, presence: true
  validates :shipping_estimates, presence: true, if: :default_payment_not_flybuy

  # searchkick autocomplete: ['name'], fields: [:name, :main_category]
  searchkick word_start: [:name, :description]

  scope :search_import, -> { includes(:tags, :fly_buy_orders, :emb_orders, :amg_orders, :armor_orders, :green_orders, :stripe_orders) }

  scope :unexpired, -> { where('end_date > ?', DateTime.now).where(status: true) }
  scope :offer_expired, -> { where('end_date < ?', DateTime.now) }
  scope :fly_buy_default_payment, -> { where(default_payment: "Fly And Buy") }
  scope :for_sell, -> { where(status_characteristic: 'sell') }
  scope :independent, -> { where(folder_id: nil) }
  scope :most_recent, -> { order(created_at: :desc) }
  scope :most_viewed, -> { order(views_count: :desc) }
  scope :not_sold_out, -> { where("amount > sold_out") }
  scope :inactive, -> { where(status: false) }
  scope :order_by_modified_date, -> { order('updated_at DESC') }
  scope :active, -> { where(status: true) }
  scope :expired_yesterday, -> { where('end_date BETWEEN ? AND ?',
                      1.day.ago.beginning_of_day,
                      1.day.ago.end_of_day
                    )}

  attr_accessor :flash_message

  self.per_page = 16

  alias :user :owner

  after_create :product_create_notification
  after_update :count_remaning_product
  before_validation :check_for_payment_account

  SELLER = 'seller'
  BUYER = 'buyer'
  INSPECTION_SERVICE_PRICE = 1
  ACTIVE = 'Active'
  INACTIVE = 'Inactive'
  TEMPLATE_HEADER = ["Product Name", "Brand", "Model", "Product SKU", "Amount in Stock", "Price", 'Valid From', 'Valid Until', 'Minimum Order Quantity', 'Description', 'Condition', 'Product Tags', 'Sell Product using']
  CONDITIONS = { new: 'New', used: 'Used', refurbished: 'Refurbished' }

  def search_data
    {
      name: name,
      description: description,
      product_tags: tags.map(&:name).reject(&:empty?).join(' '),
      start_date: start_date,
      end_date: end_date,
      status: status,
      status_characteristic: status_characteristic,
      owner_id: user_id,
      fly_buyer_ids: fly_buy_orders.map(&:buyer_id).uniq,
      stripe_buyer_ids: stripe_orders.map(&:buyer_id).uniq,
      green_buyer_ids: green_orders.map(&:buyer_id).uniq,
      armor_buyer_ids: armor_orders.map(&:buyer_id).uniq,
      amg_buyer_ids: amg_orders.map(&:buyer_id).uniq,
      emb_buyer_ids: emb_orders.map(&:buyer_id).uniq
    }
  end

  def self.newest_products
    unexpired.for_sell.most_recent
  end

  def self.most_viewed_products
    unexpired.for_sell.most_viewed
  end

  def self.available_products()
    unexpired.for_sell.not_sold_out.count
  end

  def expired?
    end_date < DateTime.now
  end

  def active_product?
    status == true
  end

  def available_amount_for_sale
    amount - sold_out
  end

  def available_payments
    ap = []
    ap << PaymentOptions[:stripe] if stripe_present?
    ap << PaymentOptions[:green] if green_present?
    ap << PaymentOptions[:amg] if amg_present?
    ap << PaymentOptions[:emb] if emb_present?
    if user.fly_buy_profile_account_added?
      ap << PaymentOptions[:fly_buy]
      ap << PaymentOptions[:same_day]
    end
    ap
  end

  def green_only_present?
    user.green_profile.present? && user.stripe_profile.nil?
  end

  def green_present?
    user.green_profile.present?
  end

  def amg_present?
    user.amg_profile.present?
  end

  def emb_present?
    user.emb_profile.present?
  end

  def stripe_present?
    user.stripe_profile.present?
  end

  def armor_present?
    user.armor_profile.present?
  end

  def armor_only_present?
    user.armor_profile.present? && user.stripe_profile.nil? && user.green_profile.nil?
  end

  def remaining_amount
    sold_out = (self.sold_out.present? ? self.sold_out : 0)
    self.amount - sold_out
  end

  def default_payment_flybuy?
    default_payment == PaymentOptions[:fly_buy]
  end

  def default_payment_same_day?
    default_payment == PaymentOptions[:same_day]
  end

  def default_payment_stripe?
    default_payment == PaymentOptions[:stripe]
  end

  def default_payment_green?
    default_payment == PaymentOptions[:green]
  end

  def default_payment_amg?
    default_payment == PaymentOptions[:amg]
  end

  def default_payment_emb?
    default_payment == PaymentOptions[:emb]
  end

  def seller_set_inspection_dates
    inspection_dates.seller_added
  end

  def negotiable?
    negotiable == true
  end

  # this is the inspection date added by seller after rejecting
  # # inspection date added by buyer
  def latest_seller_added_inspection_date
    inspection_dates.seller_added.last.get_inspection_date
  end

  def is_buyer_product_owner?(buyer)
    buyer == self.user
  end

  def is_buyer_additional_seller?(buyer)
    group.present? ? group.additional_sellers.include?(buyer) : false
  end

  def promise_fee_for_buyer
    Fee.find_by(:fee_type => "ACH").value
  end

  def default_payment_not_flybuy
    default_payment != PaymentOptions[:fly_buy]
  end

  # fly_buy_inspection_date_not_passed => if the product's default payment is
  # #   'Fly And buy', then only select those product whose all the inspection dates
  # #    has not passed
  def if_fly_buy_check_valid_inspection_date
    if default_payment_flybuy?
      return self unless inspection_dates.passed_inspection_date.count == inspection_dates.count
    else
      return self
    end
  end

  def is_group_verified_by_admin?
    group.verified_by_admin
  end

  def is_group_product?
    group.present?
  end

  def product_create_notification
    return if folder_id.present?

    users = User.tagged_with(self.tag_list, any: true)

    users.uniq.each do |user|
      if user != self.owner
        NotificationMailer.product_create_notification_email(self, user).deliver_later
        ProductNotification.new(self, user).product_created
      end
    end
  end

  def count_remaning_product
    if self.remaining_amount < self.minimum_order_quantity
      UserMailer.product_sold_out_notification_to_seller(self).deliver_later
    end
  end

  def group_admins
    admins = []
    if group.present?
      group.group_sellers.each do |group_seller|
        admins << group_seller.user if group_seller.role.name == Role::GROUP_ADMIN
      end
    end
    admins << owner
    return admins.uniq
  end

  def display_status
    status == true ? ACTIVE : INACTIVE
  end

  def owner_default_payment_verified?
    case default_payment
    when PaymentOptions[:fly_buy], PaymentOptions[:same_day]
      owner.fly_buy_profile_account_added?
    when PaymentOptions[:stripe]
      owner.stripe_profile.present?
    when PaymentOptions[:green]
      owner.green_profile.present?
    when PaymentOptions[:amg]
      owner.amg_profile.present?
    end
  end

  def orders_present?
    stripe_orders.present? || green_orders.present? || armor_orders.present? || emb_orders.present? || fly_buy_orders.present?
  end

  private

  def check_for_payment_account
    self.status = 0 unless owner_default_payment_verified?
  end
end
