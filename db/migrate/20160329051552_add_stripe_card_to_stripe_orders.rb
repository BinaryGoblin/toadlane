class AddStripeCardToStripeOrders < ActiveRecord::Migration
  def change
    add_reference :stripe_orders, :stripe_card, index: true, foreign_key: true
  end
end
