class CreateStripeCards < ActiveRecord::Migration
  def change
    create_table :stripe_cards do |t|
      t.belongs_to :stripe_customer
      t.string :stripe_card_id      
      
      t.timestamps null: false
    end
  end
end
