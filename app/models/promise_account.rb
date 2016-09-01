# == Schema Information
#
# Table name: promise_accounts
#
#  id              :integer          not null, primary key
#  bank_account_id :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  credit_card_id  :integer
#

class PromiseAccount < ActiveRecord::Base
  belongs_to :user

  attr_accessor :bank_name, :account_name, :routing_number, :account_number,
                  :account_type, :holder_type, :country
end
