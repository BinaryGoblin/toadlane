module Services
  module ActivityTracker
    class FlyBuyOrder < ActivityTracker::Base
      def track
        task_name = identify_task_name
        product = obj.product
        hash_arg = {}

        case task_name
        when :placing_order
          hash_arg[:p] = product.name
          hash_arg[:q] = product.remaining_amount
          hash_arg[:link] = "<a href='/products/#{product.id}'>View now</a>"
        when :fund_release
          hash_arg[:p] = product.name
          hash_arg[:u] = user.name
          hash_arg[:link] = "<a href='/products/#{product.id}'>View now</a>"
        end

        save_score(task_name: task_name)
        add_task(task_name: task_name, str_manipulator: hash_arg)
      end

      private

      def identify_task_name
        case obj.status
        when 'pending_inspection'
          :placing_order if obj.funds_in_escrow?
        when 'placed'
          :placing_order if obj.funds_in_escrow? && obj.order_type == 'same_day'
        when 'completed'
          :fund_release if obj.payment_release?
        when 'cancelled'
          :not_sending_funds_into_escrow unless obj.funds_in_escrow?
        end
      end
    end
  end
end
