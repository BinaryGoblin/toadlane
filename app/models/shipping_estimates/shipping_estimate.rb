# == Schema Information
#
# Table name: shipping_estimates
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  cost        :float
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  type        :string           default("PerUnit"), not null
#

class ShippingEstimate < ActiveRecord::Base
  belongs_to :product

  has_many :stripe_orders
  has_many :green_orders

  validates_numericality_of :cost

  def self.inherited(child)
    child.instance_eval do
      def model_name
        ShippingEstimate.model_name
      end
    end
    super
  end

  def self.select_options
    descendants.map{ |c| c.to_s }.sort
  end

  def calculate_shipping(stripe_order)
    raise NotImplementedError, "Subclasses must define `calculate_shipping()`."
  end
end
