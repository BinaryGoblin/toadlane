class Admin::FlyBuy::GroupVerificationsController < ApplicationController

	layout 'admin_dashboard'

	def index
		@groups = Group.where.not(product_id: nil).paginate(page: params[:page], per_page: params[:count]).order('id DESC')
	end

	def mark_group_unverify
		group = Group.find_by_id(params[:group_id])

		additional_sellers = group.additional_sellers

		product = group.product

		if group.update_attribute(:verified_by_admin, false)
			additional_sellers.each do |seller|
				UserMailer.send_group_marked_unverified_notification(product, seller).deliver_later
			end
		end

		redirect_to admin_fly_buy_group_verifications_path
	end

	def mark_group_verify
		group = Group.find_by_id(params[:group_id])

		additional_sellers = group.additional_sellers

		product = group.product

		if group.update_attribute(:verified_by_admin, true)
			additional_sellers.each do |seller|
				UserMailer.send_group_marked_verified_notification(product, seller).deliver_later
			end
		end

		redirect_to admin_fly_buy_group_verifications_path
	end
end
