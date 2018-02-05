module Services
  module ActivityTracker
    module Mixins
      module Track
        def track
          task_name = identify_task_name
          product = obj.product
          hash_arg = {}

          case task_name
          when :placing_order
            hash_arg[:p] = product.name
            hash_arg[:q] = product.remaining_amount
            hash_arg[:link] = link('View now', url_for_products(product.id))
          when :fund_release
            hash_arg[:p] = product.name
            hash_arg[:u] = user.name
            hash_arg[:link] = link('View now', url_for_products(product.id))
            hash_arg[:rank] = number_in_percentage(user.ci_lower_bound)
          end

          save_score(task_name: task_name)
          add_task(task_name: task_name, str_manipulator: hash_arg, options: { is_visible: true })
        end

        private

        def identify_task_name
          case obj.status
          when 4
            :placing_order
          when 6
            :fund_release
          when 3
            :not_sending_funds_into_escrow
          end
        end
      end
    end
  end
end
