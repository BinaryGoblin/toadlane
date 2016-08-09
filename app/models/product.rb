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
#

class Product < ActiveRecord::Base
  acts_as_commontable
  acts_as_paranoid
  is_impressionable :counter_cache => true, :column_name => :views_count, :unique => :user_id

  belongs_to :user

  self.inheritance_column = nil # So that the :type enum doesn't complain about Single Table Inheritance
  enum type: [ :on_sale, :in_demand ]

  has_paper_trail

  has_many :stripe_orders, dependent: :destroy
  has_many :green_orders, dependent: :destroy
  has_many :armor_orders, dependent: :destroy
  has_many :product_categories
  has_many :categories, through: :product_categories, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :videos, dependent: :destroy
  accepts_nested_attributes_for :images, :videos
  has_many :pricebreaks, -> { order(quantity: :asc) }, autosave: true, dependent: :destroy
  has_many :shipping_estimates, dependent: :destroy
  has_many :certificates, dependent: :destroy
  has_many :inspection_dates

  accepts_nested_attributes_for :shipping_estimates,
    :allow_destroy => true,
    :reject_if => lambda { |a| (a[:cost].blank? && a[:description].blank?) }
  belongs_to :category, class_name: "Category", foreign_key: :main_category

  accepts_nested_attributes_for :product_categories
  accepts_nested_attributes_for :pricebreaks, :reject_if => :all_blank

  validates_numericality_of :unit_price, :amount, only_integer: false, greater_than: 0, less_than: 1000000
  validates_presence_of :end_date, :status_characteristic
  validates_presence_of :shipping_estimates

  searchkick autocomplete: ['name'], fields: [:name, :main_category]

  scope :unexpired, -> { where("end_date > ?", DateTime.now).where(status: true) }

  self.per_page = 16

  def available_payments
    ap = []
    ap << "Credit Card" if user.stripe_profile.present?
    ap << "eCheck" if user.green_profile.present?
    ap << "Armor" if user.armor_profile.present?
    ap
  end

  def green_only_present?
    user.green_profile.present? && user.stripe_profile.nil?
  end

  def green_present?
    user.green_profile.present?
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

  def owner_default_payment_armor?
    user.default_payment_armor?
  end

  def seller_set_inspection_dates
    inspection_dates.seller_added
  end

  def negotiable?
    self.negotiable == true
  end
end
