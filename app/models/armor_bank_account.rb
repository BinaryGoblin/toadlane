class ArmorBankAccount < ActiveRecord::Base
  belongs_to :user
  has_paper_trail
end
