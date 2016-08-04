class AmgService
  include HTTParty
  if Rails.env.production?
    base_uri 'https://secure.advancedmerchantgroupgateway.com/api/v2/three-step'
  else
    base_uri 'https://secure.advancedmerchantgroupgateway.com/api/v2/three-step'
  end

  attr_accessor :api_key

  def initialize(api_key)
    self.api_key = api_key
  end

  def transaction_step1(params = {})
    params["api-key"] = "#{api_key}"
    response = self.class.post("/sale", { body: params })
    response_hash = Hash.from_xml(response.body)
    response_hash["response"]
  end
end
