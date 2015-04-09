class ArmorService
  attr_accessor :client
  
  def initialize()
    sandbox = if Rails.env.production? then false else true end
    secrets = Rails.application.secrets
    @client = ArmorPayments::API.new(secrets['armor_api_key'], secrets['armor_api_secret'], sandbox)
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