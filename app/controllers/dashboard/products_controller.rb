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

    negotiable = product_params["negotiable"] == "1" ? true : false

    @product = current_user.products.new(product_params.merge!(start_date: start_date)
                                          .merge!(end_date: end_date)
                                          .merge!(negotiable: negotiable)
                                          .merge!(default_payment: params["product"]["default_payment"])
                                          .except(:images_attributes,
                                                  :certificates_attributes,
                                                  :videos_attributes))

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

        if params["product"]["inspection_date_attributes"].present?
          inspection_attributes = params["product"]["inspection_date_attributes"]
          inspection_attributes.each do |inspection_attribute|
            inspection_date = DateTime.new(inspection_attribute["date(1i)"].to_i, inspection_attribute["date(2i)"].to_i, inspection_attribute["date(3i)"].to_i, inspection_attribute["date(4i)"].to_i, inspection_attribute["date(5i)"].to_i)
            @product.inspection_dates.create({date: inspection_date, creator_type: "seller", product_id: @product.id})
          end
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

    if product_params[:pricebreaks_attributes].present?
      product_params[:pricebreaks_attributes] = parse_pricebrakes product_params[:pricebreaks_attributes]
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

    if params["product"]["inspection_date_delete"].present?
      inspection_date_for_delete = params["product"].extract!(:inspection_date_delete)
    end

    negotiable = product_params["negotiable"] == "1" ? true : false

    respond_to do |format|
      if @product.update(product_params.merge!(start_date: start_date)
                  .merge!(end_date: end_date).merge!(negotiable: negotiable)
                  .merge!(default_payment: params["product"]["default_payment"])
                  .except(:images_attributes, :images_attributes_delete,
                          :certificates_attributes, :certificates_attributes_delete,
                          :videos_attributes, :videos_attributes_delete, :pricebreaks_delete))

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

        if params["product"]["inspection_date_attributes"].present?
          inspection_attributes = params["product"]["inspection_date_attributes"]
          inspection_attributes.each do |inspection_attribute|
            inspection_date = DateTime.new(inspection_attribute["date(1i)"].to_i, inspection_attribute["date(2i)"].to_i, inspection_attribute["date(3i)"].to_i, inspection_attribute["date(4i)"].to_i, inspection_attribute["date(5i)"].to_i)
            if inspection_attribute["id"].present?
              existing_inspection_date = @product.inspection_dates.find_by_id(inspection_attribute["id"])
              existing_inspection_date.update_attribute(:date, inspection_date)
            else
              @product.inspection_dates.create({date: inspection_date, creator_type: "seller", product_id: @product.id})
            end
          end
        end

        if inspection_date_for_delete
          inspection_date_for_delete[:inspection_date_delete].each do |inspection_date|
            @product.inspection_dates.find_by_id(inspection_date).destroy
          end
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

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:id, :name, :negotiable, :description, :user_id, :unit_price, :status_action, :status, :status_characteristic, :start_date, :end_date,
                                      :amount, :sold_out, :dimension_width, :dimension_height, :dimension_depth, :dimension_weight, :main_category,
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
