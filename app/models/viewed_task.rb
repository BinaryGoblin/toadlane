# == Schema Information
#
# Table name: viewed_tasks
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  task_id                :integer
#  created_at             :datetime
#  updated_at             :datetime
#
class ViewedTask < ActiveRecord::Base

  belongs_to :user
  belongs_to :task

  validates :task_id, uniqueness: { scope: :user_id }
end
