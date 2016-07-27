class Dashboard::ProductsController < DashboardController
  def index
    @products = Product.where(user_id: current_user.id).paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @products_count = @products.count
    if params["armor_order_id"].present?
      @armor_order = ArmorOrder.find_by_id(params["armor_order_id"])
      @buyer = @armor_order.buyer
    end
  end

  def edit
    set_product
    @history = PaperTrail::Version.where(item_id: @product.id).order('created_at DESC')
  end

  def new
    if current_user.profile_complete? && current_user.has_payment_account?
      @product = Product.new
    else
      if !current_user.has_payment_account?
        redirect_to dashboard_accounts_path, :flash => { :error => "You must create or link a Stripe account or a Green account or Armor account in order to accept payments."}
      else
        redirect_to dashboard_profile_path, :flash => { :error => "You must complete your profile before you can create product listings." }
      end
    end
  end

  def create
    return if !current_user.profile_complete? || !current_user.has_payment_account?

    start_date = DateTime.new(product_params["start_date(1i)"].to_i, product_params["start_date(2i)"].to_i, product_params["start_date(3i)"].to_i, product_params["start_date(4i)"].to_i, product_params["start_date(5i)"].to_i)
    end_date = DateTime.new(product_params["end_date(1i)"].to_i, product_params["end_date(2i)"].to_i, product_params["end_date(3i)"].to_i, product_params["end_date(4i)"].to_i, product_params["end_date(5i)"].to_i)

    if current_user.armor_profile.present?
      inspection_date = DateTime.new(product_params["inspection_date(1i)"].to_i, product_params["inspection_date(2i)"].to_i, product_params["inspection_date(3i)"].to_i, product_params["inspection_date(4i)"].to_i, product_params["inspection_date(5i)"].to_i)
    end

    if product_params[:pricebreaks_attributes].present?
      product_params[:pricebreaks_attributes] =  parse_pricebrakes product_params[:pricebreaks_attributes]
    end

    if product_params[:product_categories_attributes].present?
      product_params[:product_categories_attributes] = parse_categories product_params[:product_categories_attributes]
    end

    Rails.logger.info product_params.inspect

    if product_params[:images_attributes].present?
      images = product_params.extract!(:images_attributes)
    end

    if product_params[:certificates_attributes].present?
      certificates = product_params.extract!(:certificates_attributes)
    end

    if product_params[:videos_attributes].present?
      videos = product_params.extract!(:videos_attributes)
    end

    @product = current_user.products.new(product_params.merge!(start_date: start_date).merge!(end_date: end_date).merge!(inspection_date: inspection_date).except(:images_attributes, :certificates_attributes, :videos_attributes))

    respond_to do |format|
      if @product.save
        if images
          images[:images_attributes].each do |image|
            data = { image: image }
            @product.images.new(data)
            @product.save
          end
        end

        if certificates
          certificates[:certificates_attributes].each do |certificate|
            data = { uploaded_file: certificate }
            @product.certificates.new(data)
            @product.save
          end
        end

        if videos
          videos[:videos_attributes].each do |video|
            data = { video: video }
            @product.videos.new(data)
            @product.save
          end
        end

        if params[:button] == 'new'
          path = new_dashboard_product_path
        elsif params[:button] == 'edit'
          path = edit_dashboard_product_path(@product)
        else
          path = dashboard_products_path
        end

        format.html { redirect_to path }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    set_product

    start_date = DateTime.new(product_params["start_date(1i)"].to_i, product_params["start_date(2i)"].to_i, product_params["start_date(3i)"].to_i, product_params["start_date(4i)"].to_i, product_params["start_date(5i)"].to_i)
    end_date = DateTime.new(product_params["end_date(1i)"].to_i, product_params["end_date(2i)"].to_i, product_params["end_date(3i)"].to_i, product_params["end_date(4i)"].to_i, product_params["end_date(5i)"].to_i)

    if current_user.armor_profile.present?
      inspection_date = DateTime.new(product_params["inspection_date(1i)"].to_i, product_params["inspection_date(2i)"].to_i, product_params["inspection_date(3i)"].to_i, product_params["inspection_date(4i)"].to_i, product_params["inspection_date(5i)"].to_i)
    end

    if product_params[:pricebreaks_attributes].present?
      product_params[:pricebreaks_attributes] =  parse_pricebrakes product_params[:pricebreaks_attributes]
    end

    @product.categories.delete_all

    if product_params[:product_categories_attributes].present?
      product_params[:product_categories_attributes] = parse_categories product_params[:product_categories_attributes]
    end

    if product_params[:images_attributes].present?
      images = product_params.extract!(:images_attributes)
    end

    if product_params[:images_attributes_delete].present?
      for_delete = product_params.extract!(:images_attributes_delete)
    end

    if product_params[:certificates_attributes].present?
      certificates = product_params.extract!(:certificates_attributes)
    end

    if product_params[:certificates_attributes_delete].present?
      certificates_for_delete = product_params.extract!(:certificates_attributes_delete)
    end

    if product_params[:videos_attributes].present?
      videos = product_params.extract!(:videos_attributes)
    end

    if product_params[:videos_attributes_delete].present?
      videos_for_delete = product_params.extract!(:videos_attributes_delete)
    end

    if product_params[:pricebreaks_delete].present?
      pricebreak_for_delete = product_params.extract!(:pricebreaks_delete)
    end

    respond_to do |format|
      if @product.update(product_params.merge!(start_date: start_date).merge!(end_date: end_date).merge!(inspection_date: inspection_date).except(:images_attributes,
        :images_attributes_delete, :certificates_attributes, :certificates_attributes_delete, :videos_attributes, :videos_attributes_delete, :pricebreaks_delete))

        if images
          images[:images_attributes].each do |image|
            data = { image: image }
            @product.images.new(data)
            @product.save
          end
        end

        if for_delete
          for_delete[:images_attributes_delete].each do |image|
            @product.images.find(image).destroy
          end
        end

        if certificates
          certificates[:certificates_attributes].each do |certificate|
            data = { uploaded_file: certificate }
            @product.certificates.new(data)
            @product.save
          end
        end

        if certificates_for_delete
          certificates_for_delete[:certificates_attributes_delete].each do |certificate|
            @product.certificates.find(certificate).destroy
          end
        end

        if videos
          videos[:videos_attributes].each do |video|
            data = { video: video }
            @product.videos.new(data)
            @product.save
          end
        end

        if videos_for_delete
          videos_for_delete[:videos_attributes_delete].each do |video|
            @product.videos.find(video).destroy
          end
        end

        if pricebreak_for_delete
          pricebreak_for_delete[:pricebreaks_delete].each do |pricebreak|
            @product.pricebreaks.find(pricebreak).destroy
          end
        end

        if params[:button] == 'new'
          path = new_dashboard_product_path
        elsif params[:button] == 'edit'
          path = edit_dashboard_product_path(@product)
        else
          path = dashboard_products_path
        end

        format.html { redirect_to path }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    set_product
    @product.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_products_path }
    end
  end

  def delete_cascade
    if params[:products_ids].present?
      params[:products_ids].each do |id|
        Product.find(id).destroy
      end
    end

    render json: :ok
  end

  def active_cascade
    if params[:products_ids].present?
      params[:products_ids].each do |id|
        Product.find(id).update(status: true)
      end
    end

    render json: :ok
  end

  def inactive_cascade
    if params[:products_ids].present?
      params[:products_ids].each do |id|
        Product.find(id).update(status: false)
      end
    end

    render json: :ok
  end

  def viewers
    set_product
    user_ids = @product.impressions.try(:pluck, :user_id)
    @users = User.where(id: user_ids).order('id ASC')
  end

  def confirm_inspection_date
    armor_order = ArmorOrder.find_by_id(params["armor_order_id"])
    product = Product.find_by_id(params["product_id"])
    if armor_order.update_attribute(:inspection_date_approved_by_seller, true)
      UserMailer.send_inspection_date_confirm_notification_to_buyer(armor_order).deliver_now
      redirect_to product_path(product.id), :flash => { :notice => "Inspection date for #{product.name} has been set to #{armor_order.inspection_date.to_date}"}
    else
      redirect_to product_path(product.id), :flash => { :notice => armor_order.errors}
    end
  end

  def products_under_inspection
    armor_orders = ArmorOrder.where(buyer_id: current_user.id,
                                inspection_date_approved_by_seller: true,
                                inspection_date_approved_by_buyer: true)

    case params[:type]
    when 'complete'
      @orders = armor_orders.where(inspection_complete: true)
    when 'incomplete'
      @orders = armor_orders.where(inspection_complete: false)
    when 'today'
      @orders = armor_orders.where(inspection_complete: false)
                            .where('inspection_date BETWEEN ? AND ?',
                                      DateTime.now.beginning_of_day,
                                      DateTime.now.end_of_day )
    else
      @orders = armor_orders.where(inspection_complete: false)
    end
  end

  def complete_inspection
    armor_order = ArmorOrder.find_by_id(params["armor_order_id"])
    client = ArmorService.new
    action_data = {
                    "action" => "completeinspection",
                    "confirm" => true }
    binding.pry
    response = client.orders(armor_order.seller_account_id).update(armor_order.order_id, action_data)
    armor_order.update_attribute(:inspection_complete, true)
  rescue ArmorService::BadResponseError => e
    redirect_to products_under_inspection_dashboard_products_path, :flash => { :error => e.errors.values.flatten }
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:id, :name, :description, :user_id, :unit_price, :status_action, :status, :status_characteristic, :start_date, :end_date,
                                      :inspection_date, :amount, :sold_out, :dimension_width, :dimension_height, :dimension_depth, :dimension_weight, :main_category,
                                      :pricebreaks_attributes, :shipping_estimates_attributes, :shipping_estimates_delete, :sku,
                                      :slug, :images_attributes => [], :images_attributes_delete => [], :certificates_attributes => [], :certificates_attributes_delete => [], :videos_attributes => [], :videos_attributes_delete => [], :shipping_estimates_attributes => [ :id, :cost, :description, :product_id, :_destroy, :type ],
                                      :pricebreaks_attributes => [ :id, :quantity, :price, :product_id, :_destroy ],
                                      :pricebreaks_delete => [])
    end

    def parse_categories categories
      sub_categories = []

      categories.each do |category|
        sub_categories << { category_id: category }
      end

      sub_categories
    end

    def parse_pricebrakes pricebreaks
      sub_pricebreaks = []

      pricebreaks.each do |pricebreak|
        sub_pricebreaks << pricebreak
      end

      sub_pricebreaks
    end
end
