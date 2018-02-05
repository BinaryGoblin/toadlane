class AddBankStatementToFlyBuyProfile < ActiveRecord::Migration
  def change
  	add_attachment :fly_buy_profiles, :bank_statement
  end
end
