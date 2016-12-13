class Dashboard::GroupsController < ApplicationController
	layout 'user_dashboard'

	def index
		groups = Group.where(product_id: current_user.products.with_deleted.ids)
		current_user_listed_as_additional_seller = Group.joins(:group_sellers).where('group_sellers.user_id' => current_user.id)

		@groups = groups + current_user_listed_as_additional_seller
	end

	def accept_deal
		product = Product.find_by_id(params["product_id"])
		group_seller = GroupSeller.find_by_id(params["group_seller_id"])

		invited_additional_seller = group_seller.user

		if group_seller.user.terms_of_service.present?
			group_seller.update_attributes({accept_deal: true})
			UserMailer.send_additional_seller_accept_deal_to_owner(invited_additional_seller, product).deliver_later
			UserMailer.send_additional_seller_accept_deal_notification(invited_additional_seller, product).deliver_later
		else
			flash[:sign_up_error] = "You must first sign up in order to accept the role as an additional_seller. Please click on the invitation link sent via email."
		end
		redirect_to product_path(product)
	end

	def reject_deal
		product = Product.find_by_id(params["product_id"])
		group_seller = GroupSeller.find_by_id(params["group_seller_id"])

		invited_additional_seller = group_seller.user

		if group_seller.user.terms_of_service.present?
			group_seller.update_attributes({accept_deal: false})
			UserMailer.send_additional_seller_reject_deal_to_owner(invited_additional_seller, product).deliver_later
			UserMailer.send_additional_seller_reject_deal_notification(invited_additional_seller, product).deliver_later
		else
			flash[:sign_up_error] = "You must first sign up in order to reject the role as an additional_seller. Please click on the invitation link sent via email."
		end
		redirect_to product_path(product)
	end

	def show
		@group = Group.find_by_id(params[:id])
		@product = @group.product.present? ? @group.product : Product.with_deleted.find_by_id(@group.product_id)
		@group.update_attribute(:group_owner_id, @product.owner.id)
		@group_admin = Role.find_by_name("group admin")
	end

	def assign_role
		product = Product.find_by_id(params[:product_id])
		user = User.find_by_id(params["user_id"])
		group_seller = GroupSeller.find_by_id(params["group_seller_id"])
		selected_role = Role.find_by_id(params["role_id"])
		if user.has_role?'group admin'
			role = Role.find_by_name('group admin')
			role.users.delete(user)
		elsif user.has_role?'additional seller'
			role = Role.find_by_name('additional seller')
			role.users.delete(user)
		end
		user.add_role selected_role.name
		redirect_to dashboard_group_path(group_seller.group.id)
	end

	def new
		@group = Group.new
	end

	def create
    @group  = Group.new(name: params["group"]["name"].downcase, group_owner_id: current_user.id)

    if @group.valid?
			if params["group"]["create_new_product"] == "true" || params["group"]["create_new_product"] == "0"
				# render new product page with the details of group submitted
				@product = Product.new

				render "dashboard/products/new", layout: true
			elsif params["group"]["create_new_product"].nil? && params["group"]["product_id"].present?
				# a product should be selected => validation
				# # and redirect to product edit page
				@product = Product.find_by_id(group_params["product_id"])

				render "dashboard/products/edit", layout: true
			end
		else
			render action: 'new'
		end
	end

	def edit
		@group = Group.find_by_id(params["id"])
	end

	def update
		@group = Group.find(params["id"])
		if params["group"]["additional_seller_delete"].present?
    	params["group"]["additional_seller_delete"].each do |group_seller_id|
    		group_seller = GroupSeller.find_by_id(group_seller_id)

    		group_seller.destroy if group_seller.present?
    		if params["group"]["additional_seller_attributes"].present?
    			params["group"]["additional_seller_attributes"].each do |additional_seller|
    				if additional_seller["id"] == group_seller_id
	    				additional_seller.delete("user_id")
	    				additional_seller.delete("id")
	    			end
    			end
    		end
    		params["group"]["additional_seller_attributes"].first["id"]== params["group"]["additional_seller_delete"].first
    	end
    end
		if params["group"]["create_new_product"] == "true" || params["group"]["create_new_product"] == "0"
			# render new product page with the details of group submitted
			@product = Product.new
      @group  = @group.update_attributes({name: params["group"]["name"].downcase, group_owner_id: current_user.id})

			render "dashboard/products/new", layout: true
		elsif params["group"]["create_new_product"].nil? && params["group"]["product_id"].present?
			# a product should be selected => validation
			# # and redirect to product edit page
			@product = Product.find_by_id(group_params["product_id"])
      @group  = @group.update_attributes({name: params["group"]["name"].downcase, group_owner_id: current_user.id})
			
			render "dashboard/products/edit", layout: true
		end
	end

	def destroy
    group = Group.find_by_id(params["id"])
    group.destroy if group.present?
		redirect_to dashboard_groups_path
  end

  def change_visibility_of_member
  	product = Product.find_by_id(params[:product_id])
		user = User.find_by_id(params["user_id"])
		group_seller = GroupSeller.find_by_id(params["group_seller_id"])
		private_seller = params["private_seller"] == "0" ? true : false
		total_sellers_in_group = product.group.group_sellers.count
		if private_seller == true
			count = 0
			product.group.group_sellers.each do |group_seller|
				if group_seller.private_seller == true
					count = count + 1
				end
			end
		end
		if private_seller == true && total_sellers_in_group - count == 1
			flash[:error] = "You cannot change your visibility option, as all of the other group members are private. There needs to be ateast one public member in a group."
		else
			group_seller.update_attribute(:private_seller, private_seller)
		end
		redirect_to dashboard_group_path(group_seller.group.id)
  end

  def validate_group_name
		entered_group_name = params["group"]["name"].downcase
		group = Group.find_by_name(params["group"]["name"])

		if group.nil?
			group = true
		else
			group = false
		end

		respond_to do |format|
			format.json { render :json => group }
		end
  end

	private
	def group_params
    params.require(:group).permit(:name, :product_id)
  end
end
