class Fee < ActiveRecord::Base
  validates_numericality_of :value
end
