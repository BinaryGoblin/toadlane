# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  module_name :string
#  value       :decimal(5, 3)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  fee_type    :string
#

class Fee < ActiveRecord::Base
  validates_numericality_of :value

  FlyBuyReductionFeeAmount = 75.0
end
