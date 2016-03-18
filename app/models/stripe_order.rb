class StripeOrder < ActiveRecord::Base
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :product

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false).order('created_at DESC').paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: [ :not_started, :started, :shipping_estimate, :cancelled, :placed, :shipped, :completed, :challenged, :refunded ]
  
  def process_payment(card_token)
    if buyer.stripe_profile.nil?
      if !buyer.stripe_profile.stripe_customer_id.nil?
        customer = Stripe::Customer.retrieve(buyer.stripe_profile.stripe_customer_id)
      else
        customer = Stripe::Customer.create({ :source => card_token }, { :stripe_account => seller.stripe_profile.stripe_uid })
        
        buyer.stripe_profile.stripe_customer_id = customer.id
        buyer.save
      end
    else
      customer = Stripe::Customer.create({ :source => card_token }, { :stripe_account => seller.stripe_profile.stripe_uid })
      
      buyer.stripe_profile = StripeProfile.new                                         
      buyer.stripe_profile.stripe_customer_id = customer.id
      buyer.save
    end
    charge = Stripe::Charge.create({
        :customer => customer.id,
        :amount => (total * 100).to_i,
        :description => "Toadlane Purchase",
        :currency => "usd",
        :application_fee => (fee * 100).to_i
      },
      { :stripe_account => seller.stripe_profile.stripe_uid }
    )
                                   
    self.stripe_charge_id = charge.id
    
    if self.product.sold_out.nil?
      self.product.sold_out = 0
    end
    self.product.sold_out += self.count
    raise "There is not enough stock left to make this purchase." unless self.product.valid?
    
    self.started!
    self.save
  end
end
