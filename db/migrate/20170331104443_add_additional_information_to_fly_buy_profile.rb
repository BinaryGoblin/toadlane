class AddAdditionalInformationToFlyBuyProfile < ActiveRecord::Migration
  def change
    add_column :fly_buy_profiles, :additional_information, :string
  end
end
