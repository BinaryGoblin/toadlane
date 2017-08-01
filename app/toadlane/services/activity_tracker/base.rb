module Services
  module ActivityTracker
    class Base
      include ActionView::Helpers
      include ActionDispatch::Routing
      include Rails.application.routes.url_helpers

      attr_reader :user, :obj

      def initialize(user, obj)
        @user = user
        @obj = obj
      end

      def save_score(task_name:)
        task = task(task_name)

        score = if user.score.present?
          user.score
        else
          user.build_score
        end

        score.positive += task[:positive]
        score.negative += task[:negative]
        score.save
      end

      def add_task(task_name:, str_manipulator:, options: {})
        user_task = user.tasks.build(taskable: obj)

        user_task.description = task_description(task_name: task_name, str_manipulator: str_manipulator)
        user_task.assign_attributes(options)
        user_task.score = get_score(task_name)

        user_task.save
      end

      def task_description(task_name:, str_manipulator:)
        task = task(task_name)

        task[:description].present? ? task[:description] % str_manipulator : nil
      end

      private

      def get_score(task_name)
        task = task(task_name)
        task[:positive] + task[:negative]
      end

      def task(task_name)
        Services::ActivityTracker::ConfigData::TASK_LIST[task_name]
      end
    end
  end
end
