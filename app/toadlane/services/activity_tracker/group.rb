module Services
  module ActivityTracker
    class Group < ActivityTracker::Base
      def track
        product = obj.product

        path = url_for(controller: '/products', action: 'show', id: product.id, host: Toad::Application.config.action_mailer.default_url_options[:host], only_path: false)
        link = ActionController::Base.helpers.link_to(product.name, path)

        save_score(task_name: :creating_seller_group)
        add_task(task_name: :creating_seller_group, str_manipulator: { g: obj.name, link: link })
      end
    end
  end
end
