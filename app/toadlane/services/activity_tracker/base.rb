module Services
  module ActivityTracker
    class Base
      include ActionView::Helpers
      include ActionView::Context
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
        score = get_score(task_name)

        description = task_description(task_name: task_name, str_manipulator: str_manipulator)
        description = "#{description} #{formatted_number(score)}" if description.present?

        user_task = user.tasks.build(taskable: obj)
        user_task.description = description
        user_task.assign_attributes(options)
        user_task.score = score

        user_task.save
      end

      def task_description(task_name:, str_manipulator:)
        task = task(task_name)

        task[:description].present? ? task[:description] % str_manipulator : nil
      end

      def profile_image
        ActionController::Base.helpers.image_tag(user.asset(:small), class: 'img-icon-style')
      end

      def link(text, path)
        ActionController::Base.helpers.link_to(text, path)
      end

      def url_for_search(query)
        url_for(controller: '/search', action: 'index', query: query, commit: 'Find now', user_id: user.id, count: '16', host: Toad::Application.config.action_mailer.default_url_options[:host], only_path: false)
      end

      def url_for_products(query)
        url_for(controller: '/products', action: 'show', id: query, host: Toad::Application.config.action_mailer.default_url_options[:host], only_path: false)
      end

      def number_in_percentage(number)
        number_to_percentage((number * 100).round, precision: 0, separator: ',')
      end

      private

      def formatted_number(number)
        css_class_name = number.positive? ? 'positiveScore' : 'negativeScore'

        content_tag :span, class: css_class_name do
          sprintf('+%d', number)
        end
      end

      def get_score(task_name)
        task = task(task_name)
        task[:positive] - task[:negative]
      end

      def task(task_name)
        Services::ActivityTracker::ConfigData::TASK_LIST[task_name]
      end
    end
  end
end
