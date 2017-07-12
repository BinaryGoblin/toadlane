module Services
  module ActivityTracker
    class AmgProfile < ActivityTracker::Base
      def track
        save_score(task_name: :adding_amg_profile_account)
        add_task(task_name: :adding_amg_profile_account, str_manipulator: { u: user.name })
      end
    end
  end
end
