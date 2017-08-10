module Services
  module ActivityTracker
    class Product < ActivityTracker::Base
      def track
        lowest_price = obj.pricebreaks.lowest_price
        unit_price = lowest_price.price if lowest_price.present?
        unit_price = obj.unit_price unless unit_price.present?
        link_text = "#{obj.name} (#{number_to_currency(unit_price)})"

        save_score(task_name: identify_task_name)
        add_task(task_name: identify_task_name, str_manipulator: { img: profile_image, u: user.name, rank: number_in_percentage(user.ci_lower_bound), link: link(link_text, url_for_products(obj.id)) })
      end

      private

      def identify_task_name
        assets_present = obj.videos.present? || obj.images.present?

        case obj.status_characteristic
        when 'buy'
          assets_present ? :requesting_product_with_asset : :requesting_product_without_asset
        else
          assets_present ? :creating_product_with_asset : :creating_product_without_asset
        end
      end

    end
  end
end
