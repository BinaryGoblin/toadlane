class ChangeArmorOrderAccountIdToBigint < ActiveRecord::Migration
  def change
    change_column :armor_orders, :account_id, :bigint
  end
end
