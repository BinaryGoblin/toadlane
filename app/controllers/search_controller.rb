class SearchController < ApplicationController
  layout 'user_dashboard'
  before_action :check_terms_of_service

  def index
    query = params[:query].presence || '*'
    conditions = {}
    orders = {}
    orders[:created_at] = 'desc' if params[:sort_by].present? && params[:sort_by] == '1'      # new deales first
    orders[:unit_price] = 'asc' if params[:sort_by].present? && params[:sort_by] == '2'       # low to hight price
    orders[:unit_price] = 'desc' if params[:sort_by].present? && params[:sort_by] == '3'      # hight to low price

    conditions[:status_characteristic] = params[:type] if params[:type].present? && params[:type] != "all"        # sell and buy status_characteristic
    selected_category = Category.where(id: params[:cat_id]).last
    if selected_category.present? && selected_category.name != "all"
      conditions[:main_category] = params[:cat_id]
    end
    conditions[:start_date] = {lt: Time.now}
    conditions[:end_date] = {gt: Time.now}

    unless query == '*'
      @related_searches = Searchjoy::Search.connection.select_all(Searchjoy::Search.select("normalized_query, COUNT(*) as searches_count, AVG(results_count) as avg_results_count").where("normalized_query LIKE ?", "%#{query.downcase}%").group("normalized_query").order("searches_count desc, normalized_query asc").limit(5).to_sql).to_a  
    end

    @products = Product.search query, operator: "or", fields: [{name: :word }, {description: :word}], where: conditions, order: orders, page: params[:page], per_page: params[:count]
  end

  def autocomplete
    data = params[:query]
    render json: Product.unexpired.where(status_characteristic: params[:type]).where("name ILIKE ?", "%#{data}%").limit(8).collect { |p| { name: p.name, cat_id: p.main_category, category: p.category.name, unit_price: p.unit_price } }
  end
end

