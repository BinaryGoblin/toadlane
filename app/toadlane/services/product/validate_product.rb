module Services
  module product
    class validate_product
      attr_reader :product

      def initialize(product)
        @product = product
      end

      def validate
        check_product_validation
      end

      private

      def check_product_validation
        if product.active_product? && !product.expired?
      end
    end
  end
end