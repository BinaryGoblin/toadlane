class AddFieldCompanyPhoneToFlyBuyProfile < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :company_phone, :string
  end
end
