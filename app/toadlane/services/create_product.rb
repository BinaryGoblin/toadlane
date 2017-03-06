module Services
  class CreateProduct
    attr_reader :product_params, :product
    ONE = "1"

    def initialize(product_params, current_user, id = nil)
      @product_params = product_params
      @product = if id.nil?
        product = current_user.products.new(params)
      else
        product = Product.where(id: id).first
        product
      end
    end

    def update!
      Product.update(product.id, product_params)
    end

    def save!
      Product.transaction do
        product.save!
        product.owner.add_role 'group admin'
      end
    end

    private

    def negotiable
      product_params["negotiable"] == ONE ? true : false
    end

    def parse_date_time(date)
      DateTime.strptime(date, '%Y-%m-%d %I:%M %p')
    end

    def params
      product_params.merge!(start_date: parse_date_time(product_params[:start_date]))
          .merge!(end_date: parse_date_time(product_params[:end_date]))
          .merge!(negotiable: negotiable)
    end
  end
end