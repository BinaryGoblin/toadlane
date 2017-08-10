class Dashboard::OffersController < DashboardController
  include Mixins::OfferHelper

  def index
    @offers = current_user.products.offers.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @offers_count = @offers.count
  end

  def new
    @request ||= Product.where(id: params[:request_id]).first
    new_offer
  end

  def create
    @request ||= Product.where(id: params[:request_id]).first
    create_offer
  end

  def show
    set_offer

    set_nil_fly_buy_order_id_session

    impressionist(@offer)

    @stripe_order = StripeOrder.new
    if @offer.default_payment_flybuy?
      @fee = Fee.find_by(:module_name => "Fly & Buy").value
    else
      @fee = Fee.find_by(:module_name => "Stripe").value
    end
    commontator_thread_show(@offer)
    @related_products = Product.unexpired.where(main_category: @request.main_category).where.not(id: @request.id)

    if params[:fly_buy_order_id].present?
      @fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    else
      @fly_buy_order = FlyBuyOrder.new
    end
  end

  def edit
    set_offer
    raise 'Unauthorized user access!' unless authorized_user?
    edit_offer
  end

  def update
    update_offer
  end

  private

  def after_create_and_update_path
    if params[:button] == 'new'
      path = new_dashboard_offer_path(request_id: @request.id)
    elsif params[:button] == 'edit'
      path = edit_dashboard_offer_path(@offer)
    else
      path = dashboard_offers_path
    end
  end

  def authorized_user?
    @offer.owner == current_user
  end

  def set_nil_fly_buy_order_id_session
    session[:fly_buy_order_id] = nil
  end
end
