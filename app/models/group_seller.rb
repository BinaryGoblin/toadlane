# == Schema Information
#
# Table name: group_sellers
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  product_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  accept_deal :boolean
#  group_id    :integer
#

class GroupSeller < ActiveRecord::Base
	belongs_to :user
	belongs_to :product
	belongs_to :group
	has_one :additional_seller_fee, dependent: :destroy

	scope :deal_accepted, -> { where(accept_deal: true) }

	def profile_complete?
		user.profile_complete?
	end

	def fly_buy_profile_verified?
		user.fly_buy_profile_verified?
	end

	def fly_buy_profile_account_added?
		user.fly_buy_profile_account_added?
	end
end
