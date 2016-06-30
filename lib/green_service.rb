class GreenService
  include HTTParty
  if Rails.env.production?
    base_uri 'https://www.greenbyphone.com/eCheck.asmx'
  else
    base_uri 'https://www.cpsandbox.com/eCheck.asmx'
  end

  attr_accessor :client_id, :api_password

  def initialize(client_id, api_password)
    self.client_id = client_id
    self.api_password = api_password
  end

  def bill_pay_check(params = {})
    params["Client_ID"] = "#{client_id}"
    params["ApiPassword"] = "#{api_password}"
    response = self.class.post("/BillPayCheck", { body: params })
    response_hash = Hash.from_xml(response.body)
    response_hash["BillPayCheckResult"]
  end

  def bill_pay_check_no_bank_info(params = {})
    params["Client_ID"] = "#{client_id}"
    params["ApiPassword"] = "#{api_password}"
    response = self.class.post("/BillPayCheckNoBankInfo", { body: params })
    response_hash = Hash.from_xml(response.body)
    response_hash["BillPayCheckResult"]
  end

  def one_time_draft_rtv(params = {})
    params["Client_ID"] = "#{client_id}"
    params["ApiPassword"] = "#{api_password}"
    response = self.class.post("/OneTimeDraftRTV", { body: params })
    response_hash = Hash.from_xml(response.body)
    response_hash["DraftResult"]
  end
end