class ArmorService
  attr_accessor :client
  
  def initialize()
    sandbox = if Rails.env.production? then false else true end
    secrets = Rails.application.secrets
    @client = ArmorPayments::API.new(secrets['armor_api_key'], secrets['armor_api_secret'], sandbox)
  end

  def method_missing(method_name, *args, &block)
    @client.send(method_name, *args, &block)
  end

  def accounts(*args, &block)
    @client.accounts(*args, &block)
  end

  def users(*args, &block)
    @client.users(*args, &block)
  end

  def orders(*args, &block)
    @client.orders(*args, &block)
  end

  def shipmentcarriers(*args, &block)
    @client.shipmentcarriers(*args, &block)
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