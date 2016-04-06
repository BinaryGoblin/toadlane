class SearchController < ApplicationController
  layout 'user_dashboard'
  before_filter :authenticate_user!
  before_action :check_terms_of_service

  def index
    query = params[:query].presence || '*'
    conditions = {}
    orders = {}
    orders[:created_at] = 'desc' if params[:sort_by].present? && params[:sort_by] == '1'      # new deales first
    orders[:unit_price] = 'asc' if params[:sort_by].present? && params[:sort_by] == '2'       # low to hight price
    orders[:unit_price] = 'desc' if params[:sort_by].present? && params[:sort_by] == '3'      # hight to low price

    conditions[:status_characteristic] = params[:type] if params[:type].present? && params[:type] != "all"        # sell and buy status_characteristic
    conditions[:main_category] = params[:cat_id]
    conditions[:start_date] = {lt: Time.now}
    conditions[:end_date] = {gt: Time.now}

    @products = Product.search query, operator: "or", fields: [{name: :word }, {description: :word}], where: conditions, order: orders, page: params[:page], per_page: params[:count]
  end

  def autocomplete
    data = params[:query]
    render json: Product.unexpired.where(status_characteristic: params[:type]).where("name ILIKE ?", "%#{data}%").limit(8).collect { |p| { name: p.name, cat_id: p.main_category, category: p.category.name, unit_price: p.unit_price } }
  end
end

