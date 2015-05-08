class Product < ActiveRecord::Base
  belongs_to :user

  has_paper_trail

  has_many :product_categories
  has_many :categories, through: :product_categories, dependent: :destroy
  has_many :images
  has_many :pricebreaks, autosave: true
  belongs_to :category, class_name: "Category", foreign_key: :main_category
  belongs_to :tax

  accepts_nested_attributes_for :product_categories
  accepts_nested_attributes_for :pricebreaks, :reject_if => :all_blank

  validates_numericality_of :unit_price, :amount, only_integer: false
  validates_presence_of :end_date, :status_characteristic

  searchkick autocomplete: ['name'], fields: [:name, :main_category]

  scope :unexpired, -> { where("end_date > ?", DateTime.now).where(status: true) }

  self.per_page = 16

  def self.related_products_by_main_category(id)
    himself = Product.find(id)
    category = himself.main_category
    Product.unexpired.where("main_category = ?", category).where("id != ?", himself)
  end
end
