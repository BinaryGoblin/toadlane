class AddRebateToArmorInvoices < ActiveRecord::Migration
  def change
    add_column :armor_invoices, :taxes_price, :integer, default: 0
    add_column :armor_invoices, :rebate_price, :integer, default: 0
    add_column :armor_invoices, :rebate_percent, :integer, default: 0
    add_column :armor_invoices, :deleted, :boolean, default: false
  end
end
