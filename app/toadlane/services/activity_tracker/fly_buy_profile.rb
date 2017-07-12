module Services
  module ActivityTracker
    class FlyBuyProfile < ActivityTracker::Base
      def track
        save_score(task_name: :adding_fly_and_buy_account)
        add_task(task_name: :adding_fly_and_buy_account, str_manipulator: { u: user.name })
      end
    end
  end
end
