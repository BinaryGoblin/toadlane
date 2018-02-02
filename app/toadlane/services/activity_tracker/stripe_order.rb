module Services
  module ActivityTracker
    class StripeOrder < ActivityTracker::Base
      include Services::ActivityTracker::Mixins::Track
    end
  end
end
