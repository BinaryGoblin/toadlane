class Admin::FlyBuyController < ApplicationController

	layout 'admin_dashboard'

	def index
		@users = User.joins(:fly_buy_profile).paginate(page: params[:page], per_page: params[:count]).order('id DESC')
	end

	def mark_user_unverify
		user = User.find_by_id(params[:user_id])

		user.fly_buy_profile.update_attribute(:unverify_by_admin, true)
		redirect_to admin_fly_buy_index_path
	end

	def mark_user_verify
		user = User.find_by_id(params[:user_id])

		user.fly_buy_profile.update_attribute(:unverify_by_admin, false)
		redirect_to admin_fly_buy_index_path
	end
end
