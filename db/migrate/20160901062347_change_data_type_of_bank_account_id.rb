class ChangeDataTypeOfBankAccountId < ActiveRecord::Migration
  def change
    change_column :promise_accounts, :bank_account_id, :string
  end
end
