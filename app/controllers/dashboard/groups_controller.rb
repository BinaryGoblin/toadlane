class Dashboard::GroupsController < DashboardController
	layout 'user_dashboard'

	def index
		groups = Group.where(product_id: current_user.products.with_deleted.ids)
		current_user_listed_as_additional_seller = Group.joins(:group_sellers).where('group_sellers.user_id' => current_user.id)

		@groups = groups + current_user_listed_as_additional_seller
	end

  def new
    @group = Group.new
    @group.group_sellers.build
    expected_group_members(current_user)
  end

  def create
    @group  = Group.new(group_params.merge!(group_owner_id: current_user.id))

    if @group.valid?
      if params["group"]["create_new_product"] == "true"
        product_params = {
          product: { group_attributes: { name: params[:group][:name], group_sellers_attributes: params[:group][:group_sellers_attributes] } }
        }

        redirect_to new_dashboard_product_path(product_params)
      elsif params["group"]["create_new_product"].nil? && params["group"]["product_id"].present?
        product = Product.where(id: group_params["product_id"]).first

        @group.product_id = product.id
        @group.save!

        redirect_to edit_dashboard_product_path(product)
      end
    else
      render action: 'new'
    end
  end

  def edit
    if authorized_user?
      @group = find_group
      expected_group_members(@group.owner)
    else
      redirect_to :back if @group.blank?
    end
  end

  def update
    if authorized_user?
      @group = find_group
      product = Product.where(id: group_params["product_id"]).first
      if @group.present? && product.present?
        @group.update_attributes(group_params.merge!(product_id: product.id))

        redirect_to edit_dashboard_product_path(product)
      end
    end
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
		redirect_to dashboard_group_path(product.group)
	end

	def reject_deal
		product = Product.find_by_id(params["product_id"])
		group_seller = GroupSeller.find_by_id(params["group_seller_id"])

		invited_additional_seller = group_seller.user

		if group_seller.user.terms_of_service.present?
			group_seller.delete
			UserMailer.send_additional_seller_reject_deal_to_owner(invited_additional_seller, product).deliver_later
			UserMailer.send_additional_seller_reject_deal_notification(invited_additional_seller, product).deliver_later
		else
			flash[:sign_up_error] = "You must first sign up in order to reject the role as an additional_seller. Please click on the invitation link sent via email."
		end
		redirect_to dashboard_groups_path
	end

	def show
		@group = Group.find_by_id(params[:id])
		@product = @group.product.present? ? @group.product : Product.with_deleted.find_by_id(@group.product_id)
		@group.update_attribute(:group_owner_id, @product.owner.id)
		@group_admin = Role.find_by_name("group admin")
	end

	def assign_role
		product = Product.find_by_id(params[:product_id])
		group_seller = product.group.group_sellers.find_by_id(params["group_seller_id"])
    group_seller.update_attribute(:role_id, params["role_id"])
		redirect_to dashboard_group_path(group_seller.group.id)
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
    params.require(:group).permit(:name, :product_id, group_sellers_attributes: [:id, :group_id, :user_id, :fee, :role_id, :_destroy])
  end

  def find_group
    group = Group.where(id: params[:id]).first
  end

  def authorized_user?
    group_seller = find_group.group_sellers.where(user_id: current_user.id).first
    (group_seller.present? && group_seller.is_group_admin?) || find_group.owner == current_user
  end
end
