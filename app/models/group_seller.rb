# == Schema Information
#
# Table name: group_sellers
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  product_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  accept_deal    :boolean
#  group_id       :integer
#  fee            :decimal(, )
#  private_seller :boolean          default(FALSE)
#  role_id				:integer
#

class GroupSeller < ActiveRecord::Base
	#
	## private_seller => this field is defaulted as false, the user can set himself as private seller,
	### this will not show the user in the group.
	belongs_to :user
	belongs_to :product
	belongs_to :group
	belongs_to :role

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

	def private_member?
		self.role.name == Role::PRIVATE_SELLER || self.role.name == Role::PRIVATE_SUPPLIER
	end

	def is_group_admin?
		self.role.name == Role::GROUP_ADMIN
	end
end
