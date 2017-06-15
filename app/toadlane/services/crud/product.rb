module Services
  module Crud
    class Product
      attr_reader :product_params, :product
      ONE = '1'

      def initialize(product_params, current_user, id = nil)
        @product_params = product_params
        assign_inspection_date_creator
        @product = if id.nil?
          assign_group_owner(current_user.id)
          product = current_user.products.new(params)
        else
          product = ::Product.where(id: id).first
          assign_group_owner(product.owner.id)
          product.assign_attributes(product_params)
          product
        end
      end

      def save!
        ::Product.transaction do
          product.save!
        end
      end

      private

      def assign_group_owner(owner_id)
        product_params[:group_attributes].merge!(group_owner_id: owner_id) unless product_params[:group_attributes].blank?
      end

      def assign_inspection_date_creator
        product_params[:inspection_dates_attributes].each {|key, value| value[:creator_type] = ::Product::SELLER} unless product_params[:inspection_dates_attributes].blank?
      end

      def negotiable
        product_params["negotiable"] == ONE ? true : false
      end

      def parse_date_time(date)
        if date.is_a? Date
          date
        else
          DateTime.strptime(date, '%Y-%m-%d %I:%M %p')
        end
      end

      def params
        product_params.merge!(start_date: parse_date_time(product_params[:start_date]))
            .merge!(end_date: parse_date_time(product_params[:end_date]))
            .merge!(negotiable: negotiable)
      end
    end
  end
end