class MainController < ApplicationController
  def index
    if current_user.present?
      redirect_to products_path
    end
  end

  def search_by_sell
    products = Product.for_sell category_params[:id]

    products_html = products_for_category products

    render json: { products_html: products_html }, status: :ok
  end

  def search_by_buy
    products = Product.for_buy category_params[:id]

    products_html = products_for_category products

    render json: { products_html: products_html }, status: :ok
  end

  private
    def products_for_category products
      products_html = []

      products.each do |product|
        insert = render_to_string partial: '/shared/product', locals: { product: product }
        products_html << insert
      end

      products_html
    end

    def category_params
      params.require(:category).permit(:id)
    end
end
