class AddPaymentReleaseToArmorOrder < ActiveRecord::Migration
  def change
    add_column :armor_orders, :payment_release, :boolean, default: false
  end
end
