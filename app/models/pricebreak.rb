# == Schema Information
#
# Table name: pricebreaks
#
#  id         :integer          not null, primary key
#  quantity   :integer
#  price      :float
#  product_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class Pricebreak < ActiveRecord::Base
  belongs_to :product

  validates :price, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 1 }
end
