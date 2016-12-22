# == Schema Information
#
# Table name: groups
#
#  id                :integer          not null, primary key
#  name              :string
#  product_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  verified_by_admin :boolean          default(FALSE)
#  group_owner_id    :integer
#

class Group < ActiveRecord::Base
	belongs_to :product
	has_many :group_sellers
	belongs_to :owner, class_name: "User", foreign_key: :group_owner_id

	validates_uniqueness_of :name

	attr_accessor :additional_seller_ids, :create_new_product, :role

	def additional_sellers
		group_sellers.map { |group_seller| group_seller.user }
	end

	def product_name
		if product.present?
			product.name.titleize
		else
			nil
		end
	end
end
