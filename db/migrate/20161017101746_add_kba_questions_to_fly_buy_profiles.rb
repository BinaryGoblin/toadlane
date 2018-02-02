class AddKbaQuestionsToFlyBuyProfiles < ActiveRecord::Migration
  def change
  	add_column :fly_buy_profiles, :kba_questions, :json, default: '{}'
  end
end
