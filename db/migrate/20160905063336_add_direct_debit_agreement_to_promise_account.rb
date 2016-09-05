class AddDirectDebitAgreementToPromiseAccount < ActiveRecord::Migration
  def change
    add_column :promise_accounts, :direct_debit_agreement, :boolean, default: false
  end
end
