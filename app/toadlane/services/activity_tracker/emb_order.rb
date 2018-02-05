module Services
  module ActivityTracker
    class EmbOrder < ActivityTracker::Base
      include Services::ActivityTracker::Mixins::Track
    end
  end
end
