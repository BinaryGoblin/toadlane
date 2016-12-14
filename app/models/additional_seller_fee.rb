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
			total_fee_of_additional_sellers = AdditionalSellerFee.where(group_id: group.id).sum(:value)

			if total_fee_of_additional_sellers <= value
				errors.add(:value, "The additional seller fee exceeds the product's price.")
			end
		end
	end
end
