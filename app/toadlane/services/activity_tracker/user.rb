module Services
  module ActivityTracker
    class User < ActivityTracker::Base
      def track
        update_previously = obj.activities.where(description: task_description(task_name: :updating_profile, str_manipulator: { u: user.name })).present?

        if obj.tag_changed || !update_previously
          save_score(task_name: :updating_profile)
          add_task(task_name: :updating_profile, str_manipulator: { u: user.name })
        end
      end
    end
  end
end
