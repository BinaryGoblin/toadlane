module Services
  module ActivityTracker
    class FlyBuyProfile < ActivityTracker::Base
      def track
        options = { is_visible: user.related_products.present? }

        save_score(task_name: :adding_fly_and_buy_account)
        add_task(task_name: :adding_fly_and_buy_account, str_manipulator: { img: profile_image, u: user.name, rank: number_in_percentage(user.ci_lower_bound), link: link('Click here', url_for_search(user.tag_list.join(','))) }, options: options)
      end
    end
  end
end