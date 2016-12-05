# == Schema Information
#
# Table name: additional_seller_fees
#
#  id              :integer          not null, primary key
#  group_id        :integer
#  group_seller_id :integer
#  value           :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AdditionalSellerFee < ActiveRecord::Base
end
