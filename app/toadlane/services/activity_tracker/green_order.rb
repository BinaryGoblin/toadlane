module Services
  module ActivityTracker
    class GreenOrder < ActivityTracker::Base
      include Services::ActivityTracker::Mixins::Track
    end
  end
end
