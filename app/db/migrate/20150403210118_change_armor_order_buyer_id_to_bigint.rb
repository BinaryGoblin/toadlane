class ChangeArmorOrderBuyerIdToBigint < ActiveRecord::Migration
  def change
    change_column :armor_orders, :buyer_id, :bigint
  end
end
