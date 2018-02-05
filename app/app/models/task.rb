# == Schema Information
#
# Table name: tasks
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  taskable_id            :integer
#  taskable_type          :string
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#
class Task < ActiveRecord::Base

  belongs_to :user
  belongs_to :taskable, polymorphic: true
  has_many :viewed_tasks, dependent: :destroy
end
