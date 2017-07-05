module Services
  module ActivityTracker
    class GreenProfile < ActivityTracker::Base
      def track
        save_score(task_name: :adding_green_profile_account)
        add_task(task_name: :adding_green_profile_account, str_manipulator: { u: user.name })
      end
    end
  end
end
