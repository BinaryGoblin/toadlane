class AddFundsInEscrowToArmorOrder < ActiveRecord::Migration
  def change
    add_column :armor_orders, :funds_in_escrow, :boolean, default: false
  end
end
