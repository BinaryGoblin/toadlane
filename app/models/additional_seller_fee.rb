# == Schema Information
#
# Table name: additional_seller_fees
#
#  id              :integer          not null, primary key
#  group_id        :integer
#  group_seller_id :integer
#  value           :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AdditionalSellerFee < ActiveRecord::Base
	validate :check_fee

	def check_fee
		group = Group.find(self.group_id)

		if group.present?
			product = group.product
			product_unit_price = product.unit_price
			additional_sellers_except_self = AdditionalSellerFee.where(group_id: group.id).where.not(id: self.id)
			if additional_sellers_except_self.present?
				total_fee_of_additional_sellers = additional_sellers_except_self.sum(:value)

				if total_fee_of_additional_sellers.present? && value.present? && total_fee_of_additional_sellers.to_f >= product_unit_price
					errors.add(:value, "The additional seller fee exceeds the product's price.")
				end
			end
		end
	end
end
