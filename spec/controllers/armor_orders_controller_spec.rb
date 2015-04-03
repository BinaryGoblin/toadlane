require 'spec_helper'

RSpec.describe ArmorOrdersController, type: :controller do
  describe '#create' do
    let(:user) { User.create(email: Faker::Internet.safe_email, password: 'password', name: "Test User", phone: '+12223334444') }
    let(:product) { Product.create(name: "Test Product", amount: 100, unit_price: 100, end_date: 1.day.from_now, user: user) }

    let(:armor_order_params) do
      {
        armor_order: {
          product_id: product.id,
          unit_price: 100.00,
          amount: 101.00,
          count: 1,
          summary: "products to sell",
          description: "",
          taxes_price: 1.00,
          rebate_price: 0.00,
          rebate_percent: 0.00
        }
      }
    end

    it 'creates an ArmorOrder' do
      allow_any_instance_of(ArmorOrdersController).to receive(:current_user).and_return(user)

      expect { post :create, armor_order_params }.to change { ArmorOrder.count }.by(1)
    end
  end
end