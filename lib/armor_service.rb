class ArmorService
  attr_accessor :client
  
  def initialize()
    self.client = ArmorPayments::API.new(
      Rails.application.secrets['armor_api_key'], 
      Rails.application.secrets['armor_api_secret'], 
      use_sandbox?
    )
  end

  def method_missing(method_name, *args, &block)
    self.client.send(method_name, *args, &block)
  end

  def use_sandbox?
    !Rails.env.production?
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