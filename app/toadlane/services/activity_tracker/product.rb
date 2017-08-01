module Services
  module ActivityTracker
    class Product < ActivityTracker::Base
      def track
        lowest_price = obj.pricebreaks.lowest_price
        unit_price = lowest_price.price if lowest_price.present?
        unit_price = obj.unit_price unless unit_price.present?

        img = ActionController::Base.helpers.image_tag(user.asset(:small), class: 'img-icon-style')
        path = url_for(controller: '/products', action: 'show', id: obj.id, host: Toad::Application.config.action_mailer.default_url_options[:host], only_path: false)

        link_text = "#{obj.name} (#{number_to_currency(unit_price)})"
        link = ActionController::Base.helpers.link_to(link_text, path)

        assets_present = obj.videos.present? || obj.images.present?

        if assets_present
          save_score(task_name: :creating_product_with_asset)
          add_task(task_name: :creating_product_with_asset, str_manipulator: { img: img, u: user.name, link: link })
        else
          save_score(task_name: :creating_product_without_asset)
          add_task(task_name: :creating_product_without_asset, str_manipulator: { img: img, u: user.name, link: link })
        end
      end
    end
  end
end
