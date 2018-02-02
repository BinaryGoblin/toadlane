class AddCreditCardIdToPromiseAccount < ActiveRecord::Migration
  def change
    add_column :promise_accounts, :credit_card_id, :integer
  end
end
