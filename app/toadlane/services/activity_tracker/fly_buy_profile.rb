module Services
  module ActivityTracker
    class FlyBuyProfile < ActivityTracker::Base
      def track
        img = ActionController::Base.helpers.image_tag(user.asset(:small), class: 'img-icon-style')
        path = url_for(controller: '/search', action: 'index', query: user.tag_list.join(','), host: Toad::Application.config.action_mailer.default_url_options[:host], only_path: false)
        link = ActionController::Base.helpers.link_to('Click here', path)

        options = { is_visible: user.related_products.present? }
        save_score(task_name: :adding_fly_and_buy_account)
        add_task(task_name: :adding_fly_and_buy_account, str_manipulator: { img: img, u: user.name, link: link }, options: options)
      end
    end
  end
end
