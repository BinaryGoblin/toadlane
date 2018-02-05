# == Schema Information
#
# Table name: green_checks
#
#  id                 :integer          not null, primary key
#  result             :string
#  result_description :string
#  check_number       :string
#  check_id           :string
#  green_order_id     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  amount             :float
#

class GreenCheck < ActiveRecord::Base
  belongs_to :green_order
end
