# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  parent_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent_category, class_name: "Category", foreign_key: "parent_id"

  has_many :products, through: :product_categories, dependent: :destroy
  has_many :product_categories

  validates :name, presence: true

  def self.subcategories(id)
    where(parent_id: id).select(:id, :name)
  end
end
