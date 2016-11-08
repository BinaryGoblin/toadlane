class AddErrorDetailsToFLyBuyProfile < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :error_details, :json, default: '{}'
  end
end
