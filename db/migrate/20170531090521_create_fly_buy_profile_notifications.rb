class CreateFlyBuyProfileNotifications < ActiveRecord::Migration
  def change
    create_table :fly_buy_profile_notifications do |t|

      t.belongs_to  :fly_buy_profile
      t.boolean     :invalid_tin,     default: false
      t.boolean     :invalid_ssn,     default: false
      t.boolean     :mfa_pending_tin, default: false
      t.boolean     :mfa_pending_ssn, default: false

      t.timestamps null: false
    end
  end
end
