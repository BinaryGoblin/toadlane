class AddDefaultPaymentToProducts < ActiveRecord::Migration
  def change
    add_column :products, :default_payment, :string
  end
end
