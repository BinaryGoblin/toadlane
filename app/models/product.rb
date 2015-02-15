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

  searchkick autocomplete: ['name'], fields: [:name, :main_category]

  scope :own, -> (id) { where(user_id: id) }

  scope :by_count, -> (id) { limit(id) }
  scope :for_sell, -> (id) { where(main_category: id, status_characteristic: 'sell').order(:created_at).limit(16) }
  scope :for_buy, -> (id) { where(main_category: id, status_characteristic: 'buy').order(:created_at).limit(16) }

  scope :recomended, -> { where(status_action: 'recomended').order(:created_at).limit(16) }
  scope :best, -> { where(status_action: 'best').order(:created_at).limit(16) }
  scope :new_deals, -> { order(:created_at).limit(16) }  

  default_scope { where("end_date > ?", DateTime.now).where("status = 'true'") }

  scope :all_products, -> { order('updated_at DESC') }
  scope :all_offers, -> { where(status_characteristic: 'sell') }

  self.per_page = 16

  def self.related_products_by_main_category(id)
    himself = Product.unscoped.find(id)
    category = himself.main_category
    Product.where("main_category = ?", category).where("id != ?", himself)
  end
end
