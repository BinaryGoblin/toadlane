class AddUserIdToArmorInvoices < ActiveRecord::Migration
  def change
    add_column :armor_invoices, :user_id, :integer
  end
end
