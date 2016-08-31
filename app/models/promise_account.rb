# == Schema Information
#
# Table name: promise_accounts
#
#  id              :integer          not null, primary key
#  bank_account_id :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class PromiseAccount < ActiveRecord::Base
end
