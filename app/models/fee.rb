# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  module_name :string
#  value       :decimal(5, 3)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Fee < ActiveRecord::Base
  validates_numericality_of :value
end
