class Dashboard::RequestsController < DashboardController
  include Mixins::RequestHelper

  def index
    @requests = current_user.products.requests.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @requests_count = @requests.count
  end

  def new
    new_request
  end

  def create
    create_request
  end

  def show
    set_request
    @offers = @request.offers
  end

  def edit
    set_request
    raise 'Unauthorized user access!' unless authorized_user?
    edit_request
  end

  def update
    puts params
    update_request
  end

  def destroy
    set_request
    raise 'Unauthorized user access!' unless authorized_user?
    @request.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_requests_path }
    end
  end

  private

  def after_create_and_update_path
    if params[:button] == 'new'
      path = new_dashboard_request_path
    elsif params[:button] == 'edit'
      path = edit_dashboard_request_path(@request)
    else
      path = dashboard_requests_path
    end
  end

  def authorized_user?
    @request.owner == current_user
  end
end
