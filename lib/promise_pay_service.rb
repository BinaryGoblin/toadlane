class PromisePayService
  attr_accessor :client

  def initialize
    self.client = Promisepay::Client.new(
      username: Rails.application.secrets['PROMISEPAY_USERNAME'],
      token: Rails.application.secrets['PROMISEPAY_TOKEN']
    )
  end
end
