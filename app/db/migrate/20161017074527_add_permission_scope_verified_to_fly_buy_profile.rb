class AddPermissionScopeVerifiedToFlyBuyProfile < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :permission_scope_verified, :boolean, default: false
  end
end
