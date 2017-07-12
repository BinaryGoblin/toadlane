module Services
  class AddViewedTasks
    attr_reader :user, :tasks

    def initialize(user, tasks=[])
      @user = user
      @tasks = tasks
    end

    def add
      tasks.each do |task|
        user.viewed_tasks.create(task: task)
      end
    end
  end
end