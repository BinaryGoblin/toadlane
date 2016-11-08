class CreatePromiseAccounts < ActiveRecord::Migration
  def change
    create_table :promise_accounts do |t|
      t.integer :bank_account_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
