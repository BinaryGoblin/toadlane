module Services
  module ActivityTracker
    class Product < ActivityTracker::Base
      def track
        assets_present = obj.videos.present? || obj.images.present?

        if assets_present
          save_score(task_name: :creating_product_with_asset)
          add_task(task_name: :creating_product_with_asset, str_manipulator: { u: user.name, p: obj.name })
        else
          save_score(task_name: :creating_product_without_asset)
          add_task(task_name: :creating_product_without_asset, str_manipulator: { u: user.name, p: obj.name })
        end
      end
    end
  end
end
