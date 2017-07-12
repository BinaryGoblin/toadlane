module Services
  module ActivityTracker
    class EmbProfile < ActivityTracker::Base
      def track
        save_score(task_name: :adding_emb_profile_account)
        add_task(task_name: :adding_emb_profile_account, str_manipulator: { u: user.name })
      end
    end
  end
end
