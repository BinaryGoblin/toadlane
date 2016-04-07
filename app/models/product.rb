class Product < ActiveRecord::Base
  belongs_to :user

  self.inheritance_column = nil # So that the :type enum doesn't complain about Single Table Inheritance
  enum type: [ :on_sale, :in_demand ]

  has_paper_trail

  has_many :stripe_orders
  has_many :product_categories
  has_many :categories, through: :product_categories, dependent: :destroy
  has_many :images
  has_many :pricebreaks, autosave: true
  has_many :shipping_estimates
  accepts_nested_attributes_for :shipping_estimates,
    :allow_destroy => true,
    :reject_if => lambda { |a| (a[:cost].blank? && a[:description].blank?) }
  belongs_to :category, class_name: "Category", foreign_key: :main_category

  accepts_nested_attributes_for :product_categories
  accepts_nested_attributes_for :pricebreaks, :reject_if => :all_blank

  validates_numericality_of :unit_price, :amount, only_integer: false
  validates_presence_of :end_date, :status_characteristic
  validates_presence_of :shipping_estimates

  searchkick autocomplete: ['name'], fields: [:name, :main_category]

  scope :unexpired, -> { where("end_date > ?", DateTime.now).where(status: true) }

  self.per_page = 16
end