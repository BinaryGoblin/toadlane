class CreateArmorBankAccounts < ActiveRecord::Migration
  def change
    create_table :armor_bank_accounts do |t|
      t.integer :account_type
      t.string :account_location
      t.string :account_bank
      t.string :account_routing
      t.string :account_swift
      t.string :account_account
      t.string :account_iban
      t.references :user, index: true

      t.timestamps
    end
  end
end
