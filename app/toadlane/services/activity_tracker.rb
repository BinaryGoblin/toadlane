module Services
  module ActivityTracker
    def self.track(user, track_obj)
      "Services::ActivityTracker::#{track_obj.class}".constantize.new(user, track_obj).track
    end
  end
end