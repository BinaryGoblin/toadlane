module Services
  module ActivityTracker
    class Product < ActivityTracker::Base
      def track
        lowest_price = obj.pricebreaks.lowest_price
        unit_price = lowest_price.price if lowest_price.present?
        unit_price = obj.unit_price unless unit_price.present?
        link_text = "#{obj.name} (#{number_to_currency(unit_price)})"

        assets_present = obj.videos.present? || obj.images.present?

        if assets_present
          save_score(task_name: :creating_product_with_asset)
          add_task(task_name: :creating_product_with_asset, str_manipulator: { img: profile_image, u: user.name, rank: number_in_percentage(user.ci_lower_bound), link: link(link_text, url_for_products(obj.id)) })
        else
          save_score(task_name: :creating_product_without_asset)
          add_task(task_name: :creating_product_without_asset, str_manipulator: { img: profile_image, u: user.name, rank: number_in_percentage(user.ci_lower_bound), link: link(link_text, url_for_products(obj.id)) })
        end
      end
    end
  end
end
