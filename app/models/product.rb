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
#

class Product < ActiveRecord::Base
  acts_as_commontable

  belongs_to :user

  self.inheritance_column = nil # So that the :type enum doesn't complain about Single Table Inheritance
  enum type: [ :on_sale, :in_demand ]

  has_paper_trail

  has_many :stripe_orders
  has_many :green_orders
  has_many :product_categories
  has_many :categories, through: :product_categories, dependent: :destroy
  has_many :images
  accepts_nested_attributes_for :images
  has_many :pricebreaks, -> { order(quantity: :asc) }, autosave: true
  has_many :shipping_estimates
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
end
