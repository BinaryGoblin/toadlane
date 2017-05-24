class Dashboard::ProductsController < DashboardController
  include Mixins::ProductHelper

  def index
    @products = current_user.products.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @products_count = @products.count
  end

  def new
    new_product
  end

  def edit
    set_product
    raise 'Unauthorized user access!' unless authorized_user?
    edit_product
  end

  def create
    create_product
  end

  def update
    update_product
  end

  def destroy
    set_product
    send_product_deleted_message(@product)
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
        product = Product.find(id)
        if active_product? product
          product.update(status: true)
        end
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
    if user_ids.include? @product.user.id
      user_ids.delete(@product.user.id)
    end
    @users = User.where(id: user_ids).order('id ASC')
  end

  private

  def after_create_and_update_path
    if params[:button] == 'new'
      path = new_dashboard_product_path
    elsif params[:button] == 'edit'
      path = edit_dashboard_product_path(@product.id)
    else
      path = dashboard_products_path
    end
  end

  def inactive_product? product
    !product.default_payment_flybuy? || !current_user.fly_buy_profile_account_added? || product.expired?
  end

  def active_product? product
    current_user.has_payment_account? && current_user.fly_buy_profile_account_added? && !product.expired?
  end

  def send_email_to_additional_sellers product
    return unless product.group.present?
    return unless product.group.group_sellers.present?
    group_sellers = product.group.group_sellers.where(notified: false)
    Services::Notifications::AdditionalSellerNotification.new(group_sellers, product, current_user).send
  end

  def authorized_user?
    group_seller = @product.group.group_sellers.find_by_user_id(current_user.id) if @product.group.present?
    (group_seller.present? && group_seller.is_group_admin?) || @product.owner == current_user
  end

  def send_product_deleted_message(product)
    if product.group.present?
      product.group.group_sellers.each do |group_seller|
        admins = product.group_admins
        param_hash = {group: product.group.name, product: product, group_seller: group_seller.user, current_user: current_user, admins: product.group_admins}
        NotificationMailer.group_product_removed_notification_email(param_hash).deliver_later
      end
    end
  end

  # WIP
  def validate_pricebreaks
    array_of_quantity_price = product_params[:pricebreaks_attributes].each_with_object([]) do |hash, array|
      array << [ hash.last[:quantity].to_i, hash.last[:price].to_f ]
    end
    quatity_ascending_ordered = array_of_quantity_price.sort
    price_descending_ordered = array_of_quantity_price.sort_by(&:last).reverse
    quantities = array_of_quantity_price.collect(&:first)
    prices = array_of_quantity_price.collect(&:last)

    invalid_quantity = quantities.any? {|item| [1,0].include?(item) }
    invalid_price = prices.any? {|item| item.zero? || (item > product_params[:unit_price].to_f) }

    if invalid_quantity || invalid_price || (quantities.count != quantities.uniq.count) || (quatity_ascending_ordered != price_descending_ordered)
      puts 'invalid'
    else
      puts 'valid'
    end
  end
end
