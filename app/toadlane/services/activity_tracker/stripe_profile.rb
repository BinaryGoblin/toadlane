module Services
  module ActivityTracker
    class StripeProfile < ActivityTracker::Base
      def track
        save_score(task_name: :adding_stripe_account)
        add_task(task_name: :adding_stripe_account, str_manipulator: { u: user.name })
      end
    end
  end
end
