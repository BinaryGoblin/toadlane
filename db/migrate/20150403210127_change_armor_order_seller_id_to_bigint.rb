class ChangeArmorOrderSellerIdToBigint < ActiveRecord::Migration
  def change
    change_column :armor_orders, :seller_id, :bigint
  end
end
