module Mixins
  module ProductHelper
    private

    def new_product
      if params[:product].present?
        @product = Product.new(product_params)
      else
        @product = Product.new
        group_builder = @product.build_group
        group_builder.group_sellers.build
      end
      @product.inspection_dates.build
      @product.pricebreaks.build
      expected_group_members(current_user)
    end

    def edit_product
      if @product.group.blank?
        group_builder = @product.build_group
        group_builder.group_sellers.build
        expected_group_members(@product.owner)
      else
        group = @product.group
        group.group_sellers.build unless group.group_sellers.present?
        expected_group_members(group.owner)
      end

      @product.inspection_dates.build if @product.inspection_dates.blank?
      @product.pricebreaks.build if @product.pricebreaks.blank?
      @history = PaperTrail::Version.where(item_id: @product.id).order('created_at DESC')
    end

    def create_product
      product_service = Services::Crud::Product.new(product_params, product_creator)
      @product = product_service.product
      respond_to do |format|
        if @product.valid?
          product_service.save!
          @product = product_service.product
          send_email_to_additional_sellers @product
          format.html { redirect_to after_create_and_update_path }
        else
          get_expected_group_members
          format.html { render action: 'new' }
        end
      end
    end

    def update_product
      product_service = Services::Crud::Product.new(product_params, product_creator, params[:id])
      @product = product_service.product
      respond_to do |format|
        if @product.valid?
          product_service.save!
          @product = product_service.product
          send_email_to_additional_sellers @product
          format.html { redirect_to after_create_and_update_path }
        else
          get_expected_group_members
          format.html { render action: 'edit' }
        end
      end
    end

    def expected_group_members(user)
      @expected_group_members = User.ordered_by_name.select {|u| u.id != user.id }
    end

    def set_product
      @product = Product.where(id: params[:id]).first
    end

    def send_email_to_additional_sellers product
      return unless product.group.present?
      return unless product.group.group_sellers.present?
      group_sellers = product.group.group_sellers.where(notified: false)
      Services::Notifications::AdditionalSellerNotification.new(group_sellers, product, current_user).send
    end

    def get_expected_group_members
      if @product.group.blank?
        expected_group_members(current_user)
      else
        group = @product.group
        expected_group_members(group.owner)
      end
    end

    def product_params
      params.require(:product)
      .permit(:id, :name, :negotiable, :description,
        :user_id, :unit_price, :status_action,
        :status, :status_characteristic, :start_date,
        :end_date, :amount, :sold_out, :dimension_width,
        :dimension_height, :dimension_depth,
        :dimension_weight, :main_category, { tag_list: []}, :default_payment, :fee_percent, :sku,
        :slug, images_attributes: [:id, :image, :product_id, :_destroy],
        :certificates_attributes => [:id, :uploaded_file, :_destroy],
        :videos_attributes => [:id, :video, :product_id, :_destroy], :videos_attributes_delete => [],
        :shipping_estimates_attributes => [ :id, :cost, :description, :product_id, :_destroy, :type ],
        :pricebreaks_attributes => [ :id, :quantity, :price, :product_id, :_destroy ], :inspection_dates_attributes => [:id, :date, :product_id, :_destroy],
        group_attributes: [:id, :name, :product_id, :_destroy, group_sellers_attributes: [:id, :group_id, :user_id, :fee, :_destroy, :role_id]],
        # :product_categories_attributes => [:id, :product_id, :category_id]
      )
    end

    def product_creator
      product_params[:user_id].blank? ? current_user : User.where(id: product_params[:user_id]).first
    end
  end
end