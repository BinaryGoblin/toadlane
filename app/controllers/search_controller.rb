class SearchController < ApplicationController
  layout 'user_dashboard'
  before_action :check_terms_of_service
  before_filter :authenticate_user!

  def index
    query = params[:query].presence || '*'
    conditions = {}
    orders = {}

    case params[:sort_by]
    when '1'
      orders[:created_at] = 'desc' # new deales first
    when '2'
      orders[:unit_price] = 'asc'  # low to hight price
    when '3'
      orders[:unit_price] = 'desc' # hight to low price
    end

    conditions[:status_characteristic] = case params[:type]
    when 'sell'
      params[:type]
    when 'buy'
      params[:type]
    else
      { not: 'offer' }
    end

    conditions[:start_date] = { lt: Time.now }
    conditions[:end_date] = { gt: Time.now }
    conditions[:status] = true

    selected_category = Category.where(id: params[:cat_id]).where.not(name: 'all')
    conditions[:main_category] = params[:cat_id] if selected_category.present?

    if params[:user_id].present?
      user = User.find_by(id: params[:user_id])

      conditions[:or] = [
        [
          { owner_id: user.id },
          { fly_buyer_ids: user.id },
          { stripe_buyer_ids: user.id },
          { green_buyer_ids: user.id },
          { armor_buyer_ids: user.id },
          { amg_buyer_ids: user.id },
          { emb_buyer_ids: user.id }
        ]
      ] if user.present?
    end

    @products = Product.search query, operator: 'or', fields: [{ name: :word_start }, { description: :word_start }, :product_tags], where: conditions, order: orders, page: params[:page], per_page: params[:count], track: { user_id: current_user.try(:id) }

    unless query == '*'
      query_arr_with_percentage = query.split(',').map {|val| "%#{val.strip}%" }

      @related_searches = Searchjoy::Search.connection.select_all(Searchjoy::Search.select('normalized_query, COUNT(*) as searches_count, AVG(results_count) as avg_results_count').where('normalized_query ILIKE ANY ( array[?] )', query_arr_with_percentage).group('normalized_query').order('searches_count desc, normalized_query asc').limit(5).to_sql).to_a
    end
  end

  def autocomplete
    render json: Product.unexpired.where(status_characteristic: params[:type]).where('name ILIKE ?', "%#{params[:query]}%").limit(8).collect { |p| { name: p.name, cat_id: p.main_category, category: p.category.name, unit_price: p.unit_price } }
  end
end
