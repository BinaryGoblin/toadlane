class ArmorService
  attr_accessor :client

  def initialize(api_key: nil, api_secret: nil, sandbox: nil)
    self.client = ArmorPayments::API.new(
      api_key       || Rails.application.secrets['armor_api_key'],
      api_secret    || Rails.application.secrets['armor_api_secret'],
      if sandbox.nil? then !Rails.env.production? else sandbox end
    )
  end

  def method_missing(method_name, *args, &block)
    self.client.send(method_name, *args, &block)
  end
end

class ArmorService
  class BadResponseError < StandardError;
    attr_accessor :response

    def initialize(response)
      @response = response
      super(response.body)
    end

    def errors
      response.data[:body]["errors"]
    end
  end
end

module ArmorPayments
  class Resource
    def request(method, params)
      response = connection.send(method, params)
      if response.get_header('Content-Type') =~ /json/i
        response.body = JSON.parse response.body
      end
      if !response.status.between?(200,299)
        raise ArmorService::BadResponseError.new(response)
      end
      response
    end
  end
end
