class AddEncryptedFingerprintToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :encrypted_fingerprint, :string
  end
end
