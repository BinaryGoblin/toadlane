module Services
  module ActivityTracker
    class User < ActivityTracker::Base
      def track
        update_previously = user.activities.where(Task.arel_table[:description].matches('% updated their profile.%')).present?

        if obj.tag_changed || !update_previously
          options = { is_visible: obj.tag_changed }

          save_score(task_name: :updating_profile)
          add_task(task_name: :updating_profile, str_manipulator: { img: profile_image, u: user.name, rank: number_in_percentage(user.ci_lower_bound), link: link('Click here', url_for_search(obj.tag_list.join(', '))) }, options: options)
        end
      end
    end
  end
end
