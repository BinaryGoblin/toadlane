class GreenOrder < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  belongs_to :shipping_estimate
  belongs_to :address

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false).order('created_at DESC').paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: [ :not_started, :started, :shipping_estimate, :cancelled, :placed, :shipped, :completed, :challenged, :refunded ]

  # green_params: Hash    is the input from buyer
  # seller_id:    Integer is required to pay to their account
  # amount:       Float   is the amount to be transferred from buyer to seller
  # RETURNS:      Hash    includes responses from the API request
  def self.make_request(green_params = {}, seller_id = nil, amount = 0.0)
    seller = User.find_by_id(seller_id)
    green_profile = seller.try(:green_profile)
    if seller.present? && green_profile.present?
      api_params = green_api_ready_params(
          green_params,
          amount
      )
      green_service = GreenService.new(
          green_profile.green_client_id,
          green_profile.green_api_password
      )
      if has_green_bank_info?(green_params)
        green_service.bill_pay_check(api_params)
      else
        green_service.bill_pay_check_no_bank_info(api_params)
      end
    else
      {
          result: "404",
          result_description: "Seller not found or invalid Green Profile",
          check_number: "",
          check_id: ""
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
    def self.has_green_bank_info?(green_params)
      ![green_params[:routing_number], green_params[:account_number], green_params[:bank_name]].any? {|p| p.blank?}
    end

    def self.green_api_ready_params(green_params, amount)
      api_ready_params = {}
      api_ready_params["Name"] = "#{green_params[:name]}"
      api_ready_params["Address1"] = "#{green_params[:address1]}"
      api_ready_params["Address2"] = "#{green_params[:address2]}"
      api_ready_params["City"] = "#{green_params[:city]}"
      api_ready_params["State"] = "#{green_params[:state]}"
      api_ready_params["Zip"] = "#{green_params[:zip]}"
      api_ready_params["Country"] = "#{green_params[:country]}"
      api_ready_params["CheckMemo"] = "#{green_params[:check_memo]}"
      api_ready_params["CheckAmount"] = "#{amount}"
      api_ready_params["CheckDate"] = "#{green_params[:check_date]}"
      api_ready_params["CheckNumber"] = "#{green_params[:check_number]}"
      api_ready_params["x_delim_data"] = ""
      api_ready_params["x_delim_char"] = ""
      if has_green_bank_info?(green_params)
        api_ready_params["RoutingNumber"] = "#{green_params[:routing_number]}"
        api_ready_params["AccountNumber"] = "#{green_params[:account_number]}"
        api_ready_params["BankName"] = "#{green_params[:bank_name]}"
      end
      api_ready_params
    end
end
