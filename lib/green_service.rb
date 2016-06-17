class GreenService
  include HTTParty
  base_uri 'GreenByPhone.com/eCheck.asmx'

  attr_accessor :client_id, :api_password

  def initialize(client_id, api_password)
    self.client_id = client_id
    self.api_password = api_password
  end

  def bill_pay_check(params = {})
    params["client_id"] = client_id
    params["apiPassword"] = api_password
    self.class.post("/BillPayCheck", params)
  end

  def bill_pay_check_no_bank_info(params = {})
    params["client_id"] = client_id
    params["apiPassword"] = api_password
    self.class.post("/BillPayCheckNoBankInfo", params)
  end
end