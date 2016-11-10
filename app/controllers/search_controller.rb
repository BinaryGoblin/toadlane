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

    @products = Product.search query, operator: "or", fields: [{name: :word_start }, {description: :word_start}], where: conditions, order: orders, page: params[:page], per_page: params[:count], track: {user_id: current_user.try(:id)}

    unless query == '*'
      query_arr_with_percentage = query.split(" ").map {|val| "%#{val}%" }
      @related_searches = Searchjoy::Search.connection.select_all(Searchjoy::Search.select("normalized_query, COUNT(*) as searches_count, AVG(results_count) as avg_results_count").where("normalized_query ILIKE ANY ( array[?] )", query_arr_with_percentage).group("normalized_query").order("searches_count desc, normalized_query asc").limit(5).to_sql).to_a  
    end
  end

  def autocomplete
    data = params[:query]
    render json: Product.unexpired.where(status_characteristic: params[:type]).where("name ILIKE ?", "%#{data}%").limit(8).collect { |p| { name: p.name, cat_id: p.main_category, category: p.category.name, unit_price: p.unit_price } }
  end
end

