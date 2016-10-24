class ChangeDataTypeForSsnAndTin < ActiveRecord::Migration
  def change
  	change_column :fly_buy_profiles, :ssn_number, :string
  	change_column :fly_buy_profiles, :tin_number, :string
  end
end
