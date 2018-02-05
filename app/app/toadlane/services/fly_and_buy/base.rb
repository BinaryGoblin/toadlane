module Services
  module FlyAndBuy

    class Base < HtmlRenderer

      attr_reader :fly_buy_order, :fly_buy_profile

      def initialize(fly_buy_order, fly_buy_profile)
        @fly_buy_order = fly_buy_order
        @fly_buy_profile = fly_buy_profile
      end

      protected

      def update_fly_buy_profile(**options)
        fly_buy_profile.update_attributes(options)
      end

      def update_fly_buy_order(**options)
        fly_buy_order.update_attributes(options)
      end

      def update_product_count
        product = fly_buy_order.product
        product.sold_out += fly_buy_order.count
        product.save
      end

      def notify_order_details_to_user(method_name:, extra_arg: nil)
        if extra_arg.present?
          UserMailer.send(method_name, fly_buy_order, extra_arg)
        else
          UserMailer.send(method_name, fly_buy_order)
        end.deliver_later
      end

      def encode_attachment(file_tempfile:, file_type:)
        file_content = open(parse_original_path(file_tempfile.gsub(/\?\d+$/, ''))) { |f| f.read }

        encode_64(file_content, file_type)
      end

      def encode_file(file:, type:)
        content = IO.read(file)

        encode_64(content, type)
      end

      def convert_invoice_to_image(fly_buy_order, user)
        render_html(View.new.tap do |v|
          v.partial = 'shared/invoice'
          v.locals = { order: fly_buy_order, user: user }
        end)
      end

      def seller_account_type(fly_buy_profile)
        if fly_buy_profile.outside_the_us?
          'WIRE-INT'
        else
          'WIRE-US'
        end
      end

      def calulate_total_fee(fly_buy_order, per_unit_commission)
        fly_buy_order.count * per_unit_commission.to_f
      end

      def get_error_details(error_response={})
        http_code = error_response['http_code'] || error_response[:http_code]

        if ['500', '502', '503', '504'].include?(http_code.to_s)
          { en: 'Sorry for the inconvenience, encounter a SynapsePay server error. Please try again later.' }
        else
          error_response['error'] || error_response[:error]
        end
      end

      private

      def encode_64(content, type)
        encoded = Base64.encode64(content)
        mime_padding = "data:#{type};base64,"

        "#{mime_padding}#{encoded}"
      end

      def parse_original_path(path)
        Rails.env.development? ? File.join(Rails.root, 'public', path) : path
      end
    end
  end
end
