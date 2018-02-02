class AddSsnAgreementToFlyBuyProfiles < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :ssn_agreement, :boolean
  end
end
