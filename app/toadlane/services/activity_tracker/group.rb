module Services
  module ActivityTracker
    class Group < ActivityTracker::Base
      def track
        product = obj.product

        save_score(task_name: :creating_seller_group)
        add_task(task_name: :creating_seller_group, str_manipulator: { g: obj.name, link: link(link_text, url_for_products(product.id)) })
      end
    end
  end
end
