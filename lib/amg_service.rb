class AmgService
  include HTTParty
  if Rails.env.production?
    base_uri 'https://secure.advancedmerchantgroupgateway.com/api'
  else
    base_uri 'https://secure.advancedmerchantgroupgateway.com/api'
  end

  attr_accessor :username, :password

  def initialize(username, password)
    self.username = username
    self.password = password
  end

  def direct_post(params = {})
    params["username"] = "#{username}"
    params["password"] = "#{password}"
    response = self.class.post("/transact.php", { body: params })
    Rack::Utils.parse_nested_query(response)
  end
end
