# == Schema Information
#
# Table name: scores
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  positive               :integer          default(0)
#  negative               :integer          default(0)
#  created_at             :datetime
#  updated_at             :datetime
#
class Score < ActiveRecord::Base

  belongs_to :user
end
