# == Schema Information
#
# Table name: additional_seller_fee_transactions
#
#  id                         :integer          not null, primary key
#  fly_buy_order_id           :integer
#  user_id                    :integer
#  group_id                   :integer          # used for tracking if addition seller deleted from group
#  synapse_transaction_id     :string
#  fee                        :float
#  is_paid                    :float            default(false)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null

class AdditionalSellerFeeTransaction < ActiveRecord::Base
  belongs_to :fly_buy_order
  belongs_to :user
end
