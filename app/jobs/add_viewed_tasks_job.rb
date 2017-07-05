class AddViewedTasksJob < ActiveJob::Base

  queue_as :add_viewed_tasks

  def perform(user, tasks)
    Services::AddViewedTasks.new(user, tasks).add
  end
end