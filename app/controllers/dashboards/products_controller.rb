class Dashboards::ProductsController < ::DashboardsController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.where(user_id: current_user.id).paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @products_count = @products.count
  end

  def edit
    @history = PaperTrail::Version.where(item_id: @product.id).order('created_at DESC')
  end

  def new
    if current_user.armor_api_account_exists?
      @product = Product.new
    else
      redirect_to dashboards_profile_path
    end
  end

  def create

    return if !current_user.armor_api_account_exists?

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
      product_params.except!(:images_attributes)
    end

    @product = current_user.products.new(product_params.merge!(start_date: start_date).merge!(end_date: end_date))

    respond_to do |format|
      if @product.save
        if images
          images[:images_attributes].each do |image|
            data = { image: image }
            @product.images.new(data)
            @product.save
          end
        end

        if params[:button] == 'new'
          path = new_dashboards_product_path
        elsif params[:button] == 'edit'
          path = edit_dashboards_product_path(@product)
        else
          path = dashboards_products_path
        end

        format.html { redirect_to path }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    start_date = DateTime.new(product_params["start_date(1i)"].to_i, product_params["start_date(2i)"].to_i, product_params["start_date(3i)"].to_i, product_params["start_date(4i)"].to_i, product_params["start_date(5i)"].to_i)
    end_date = DateTime.new(product_params["end_date(1i)"].to_i, product_params["end_date(2i)"].to_i, product_params["end_date(3i)"].to_i, product_params["end_date(4i)"].to_i, product_params["end_date(5i)"].to_i)

    @product.categories.delete_all

    if product_params[:product_categories_attributes].present?
      product_params[:product_categories_attributes] = parse_categories product_params[:product_categories_attributes]
    end

    if product_params[:images_attributes].present?
      images = product_params.extract!(:images_attributes)
      params.except!(product_params[:images_attributes])
    end

    if product_params[:images_attributes_delete].present?
      for_delete = product_params.extract!(:images_attributes_delete)
      params.except!(product_params[:images_attributes_delete])
    end

    if product_params[:pricebreaks_delete].present?
      pricebreak_for_delete = product_params.extract!(:pricebreaks_delete)
      params.except!(product_params[:pricebreaks_delete])
    end

    respond_to do |format|
      if @product.update(product_params.merge!(start_date: start_date).merge!(end_date: end_date))

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

        if pricebreak_for_delete
          pricebreak_for_delete[:pricebreaks_delete].each do |pricebreak|
            @product.pricebreaks.find(pricebreak).destroy
          end
        end

        if params[:button] == 'new'
          path = new_dashboards_product_path
        elsif params[:button] == 'edit'
          path = edit_dashboards_product_path(@product)
        else
          path = dashboards_products_path
        end

        format.html { redirect_to path }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to dashboards_products_path }
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

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit!
      # (:ids, :name, :description, :start_date, :end_date, :user_id, :unit_price, :tax_level, :status_action, :status, :start_date, :end_date, :button, :amount, :sold_out, :dimension_width, :dimension_height, :dimension_depth, :dimension_weight, :main_category, :images => [])
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
