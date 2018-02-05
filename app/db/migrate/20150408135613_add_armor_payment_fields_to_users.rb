class AddArmorPaymentFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :armor_account_id, :bigint
    add_column :users, :armor_user_id, :bigint
  end
end
