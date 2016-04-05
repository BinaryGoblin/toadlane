class StripeOrder < ActiveRecord::Base
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :product
  belongs_to :stripe_card
  belongs_to :shipping_estimate
  accepts_nested_attributes_for :shipping_estimate
  belongs_to :address
  accepts_nested_attributes_for :address

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false)
    .order('created_at DESC')
    .paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: [ :not_started, :started, :shipping_estimate, :cancelled, :placed, :shipped, :completed, :challenged, :refunded ]
  
  def start_stripe_order(card_token)
    stripe_customer = StripeCustomer.find_by(:user => buyer)
    
    if stripe_customer.nil?
      customer = Stripe::Customer.create( :source => card_token )
      raise "Failed to create Stripe Customer." if customer.nil?
      
      stripe_customer = StripeCustomer.new({ :user => buyer, :stripe_customer_id => customer.id })
      raise "Failed to save Stripe Customer." unless stripe_customer.save
      
      card = customer.sources.first
    else
      customer = Stripe::Customer.retrieve( stripe_customer.stripe_customer_id )
      card = customer.sources.create( :source => card_token )
    end
      
    
    stripe_card = stripe_customer.stripe_cards.new({ :stripe_card_id => card.id })
    raise "Failed to save Stripe Card." unless stripe_card.save
    
    self.stripe_card = stripe_card
    raise "Failed to attach card to order." unless self.save
    
    if self.product.sold_out.nil?
      self.product.sold_out = 0
    end
    
    self.product.sold_out += self.count
    raise "There is not enough stock left to make this purchase." unless self.product.valid?
    
    self.started!
    raise "Failed to save order." unless self.save
  end
  
  def process_payment()
    customer = Stripe::Customer.retrieve(buyer.stripe_customer.stripe_customer_id)
    
    token = Stripe::Token.create(
      {:customer => customer, :card => stripe_card.stripe_card_id },
      {:stripe_account => seller.stripe_profile.stripe_uid } # id of the connected account
    )
    
    charge = Stripe::Charge.create({
        :amount => (total * 100).to_i,
        :application_fee => (fee * 100).to_i,
        :description => "Purchase on Toadlane.com",
        :currency => "usd",
        :source => token
      },
      { :stripe_account => seller.stripe_profile.stripe_uid }
    )
                                   
    stripe_charge_id = charge.id
    
    if self.product.sold_out.nil?
      self.product.sold_out = 0
    end
      
    self.product.sold_out += self.count
    raise "There is not enough stock left to make this purchase." unless self.product.valid?
    
    self.placed!
    self.save
  end
end