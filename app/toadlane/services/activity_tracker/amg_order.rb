module Services
  module ActivityTracker
    class AmgOrder < ActivityTracker::Base
      include Services::ActivityTracker::Mixins::Track
    end
  end
end
