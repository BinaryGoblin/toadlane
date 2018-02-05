class SetDefaultArmorOrderStatusToNotStarted < ActiveRecord::Migration
  def change
    change_column :armor_orders, :status, :integer, default: 0
  end
end
