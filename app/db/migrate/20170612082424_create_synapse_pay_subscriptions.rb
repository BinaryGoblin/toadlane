class CreateSynapsePaySubscriptions < ActiveRecord::Migration
  def change
    create_table :synapse_pay_subscriptions do |t|
      t.string :subscription_id

      t.timestamps null: false
    end
  end
end
