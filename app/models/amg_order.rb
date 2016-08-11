class AmgOrder < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  belongs_to :shipping_estimate
  belongs_to :address

  attr_accessor :first_name, :last_name, :address1, :rebate_percent

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false).order('created_at DESC').paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: [ :not_started, :started, :shipping_estimate, :cancelled, :placed, :shipped, :completed, :challenged, :refunded ]

  # amg_params: Hash    is the input from buyer
  # seller_id:    Integer is required to pay to their account
  # amount:       Float   is the amount to be transferred from buyer to seller
  # RETURNS:      Hash    includes responses from the API request
  def self.make_request(amg_params = {}, seller_id = nil, product_id = nil, buyer_id = nil, amount = 0.0)
    seller = User.find_by_id(seller_id)
    amg_profile = seller.try(:amg_profile)
    if seller.present? && amg_profile.present?
      api_params = amg_api_ready_params(
        amg_params,
        amount
      )
      amg_service = AmgService.new(
        amg_profile.amg_api_key
      )
      amg_service.transaction_step1(api_params)
    else
      {
        "result" => "3",
        "result-text" => "Seller not found or invalid AMG Profile",
        "transaction-id" => "",
        "result-code" => "",
        "form-url" => ""
      }
    end
  end

  def place_order
    product.sold_out += count
    self.product.save
    if shipping_estimate.nil?
      raise "No shipping estimate."
    end
    self.placed!
    self.save
  end

  private_class_method
    def self.amg_api_ready_params(amg_params, product_id, buyer_id, amount)
      api_ready_params = {}
      api_ready_params["redirect-url"] = "#{root_url}products/#{product_id}/checkout/amg"
      api_ready_params["descriptor"] = "#{amg_params[:name]}"
      api_ready_params["descriptor-phone"] = "#{amg_params[:phone]}"
      api_ready_params["descriptor-address"] = "#{amg_params[:address1]}"
      api_ready_params["descriptor-city"] = "#{amg_params[:address_city]}"
      api_ready_params["descriptor-state"] = "#{amg_params[:address_state].try(:upcase)}"
      api_ready_params["descriptor-postal"] = "#{amg_params[:address_zip]}"
      api_ready_params["descriptor-country"] = "#{amg_params[:address_country]}"
      api_ready_params["amount"] = "#{amount}"
      api_ready_params["order-date"] = "#{Time.now.strftime("%m/%d/%Y")}"
      api_ready_params
    end
end
