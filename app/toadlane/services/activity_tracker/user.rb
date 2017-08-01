module Services
  module ActivityTracker
    class User < ActivityTracker::Base
      def track
        img = ActionController::Base.helpers.image_tag(user.asset(:small), class: 'img-icon-style')
        path = url_for(controller: '/search', action: 'index', query: obj.tag_list.join(', '), host: Toad::Application.config.action_mailer.default_url_options[:host], only_path: false)
        link = ActionController::Base.helpers.link_to('Click here', path)

        update_previously = user.activities.where(Task.arel_table[:description].matches('% updated their profile.%')).present?

        if obj.tag_changed || !update_previously
          options = { is_visible: obj.tag_changed }

          save_score(task_name: :updating_profile)
          add_task(task_name: :updating_profile, str_manipulator: { u: user.name, img: img, link: link }, options: options)
        end
      end
    end
  end
end
