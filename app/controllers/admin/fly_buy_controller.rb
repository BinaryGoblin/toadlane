class Admin::FlyBuyController < ApplicationController

	layout 'admin_dashboard'

	def index
		@users = User.joins(:fly_buy_profile).paginate(page: params[:page], per_page: params[:count]).order('id DESC')

	end

end
