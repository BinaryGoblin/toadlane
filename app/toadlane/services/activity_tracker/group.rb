module Services
  module ActivityTracker
    class Group < ActivityTracker::Base
      def track
        save_score(task_name: :creating_seller_group)
        add_task(task_name: :creating_seller_group, str_manipulator: { g: obj.name, p: obj.product.name })
      end
    end
  end
end
