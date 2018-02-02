class DropArmorBankAccounts < ActiveRecord::Migration
  def change
    drop_table :armor_bank_accounts
  end
end
