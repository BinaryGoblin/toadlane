class AddUnverifyByAdmin < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :unverify_by_admin, :boolean, default: false
  end
end
