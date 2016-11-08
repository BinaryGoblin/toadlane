# == Schema Information
#
# Table name: amg_orders
#
#  id                   :integer          not null, primary key
#  buyer_id             :integer
#  seller_id            :integer
#  product_id           :integer
#  status               :integer
#  unit_price           :float
#  count                :integer
#  fee                  :float
#  rebate               :float
#  total                :float
#  summary              :string
#  description          :text
#  tracking_number      :string
#  deleted              :boolean
#  shipping_cost        :float
#  address_name         :string
#  address_city         :string
#  address_state        :string
#  address_zip          :string
#  address_country      :string
#  shipping_estimate_id :integer
#  address_id           :integer
#  transaction_id       :string
#  authorization_code   :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class AmgOrder < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  belongs_to :shipping_estimate
  belongs_to :address
  has_many :notifications, dependent: :destroy

  attr_accessor :first_name, :last_name, :address1, :rebate_percent

  before_create :default_delete_false

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
        product_id,
        buyer_id,
        amount
      )
      amg_service = AmgService.new(
        amg_profile.username,
        amg_profile.password
      )
      amg_service.direct_post(api_params)
    else
      {
        "response" => "3",
        "responsetext" => "Seller not found or invalid AMG Profile",
        "authcode" => "",
        "transactionid" => "",
        "avsresponse" => "",
        "cvvresponse" => "",
        "orderid" => "",
        "type" => "sale",
        "response_code" => ""
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

  def default_delete_false
    self.deleted ||= false
    self.status ||= 0
  end

  private_class_method
  def self.amg_api_ready_params(amg_params, product_id, buyer_id, amount)
    api_ready_params = {}
    api_ready_params["type"] = "sale"
    api_ready_params["first_name"] = "#{amg_params[:first_name]}"
    api_ready_params["last_name"] = "#{amg_params[:last_name]}"
    api_ready_params["address1"] = "#{amg_params[:address1]}"
    api_ready_params["city"] = "#{amg_params[:address_city]}"
    api_ready_params["state"] = "#{amg_params[:address_state].try(:upcase)}"
    api_ready_params["zipcode"] = "#{amg_params[:address_zip]}"
    api_ready_params["country"] = "#{amg_params[:address_country]}"
    api_ready_params["ccnumber"] = "#{amg_params['billing-cc-number']}"
    api_ready_params["ccexp"] = "#{amg_params['billing-cc-exp']}"
    api_ready_params["cvv"] = "#{amg_params['billing-cvv']}"
    api_ready_params["amount"] = "#{amount}"
    api_ready_params["order_description"] = "p:#{product_id}u:#{buyer_id}t:#{Time.now.to_i}"
    api_ready_params
  end
end
