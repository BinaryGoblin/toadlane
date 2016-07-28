class AddPaymentReleaseUrlToArmorOrder < ActiveRecord::Migration
  def change
    add_column :armor_orders, :payment_release_url, :string
  end
end
