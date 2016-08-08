class InspectionDate < ActiveRecord::Base
  belongs_to :product, class_name: 'Product', foreign_key: 'product_id'
  belongs_to :armor_order, class_name: 'ArmorOrder', foreign_key: 'armor_order_id'

  def get_inspection_date
    date.strftime("%B %d, %Y, %I:%M %p")
  end
end
