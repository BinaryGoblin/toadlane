class ArmorService
  attr_accessor :client, :account, :user, :order
  
  def initialize()
    sandbox = if Rails.env.production? then false else true end
    secrets = Rails.application.secrets
    @client = ArmorPayments::API.new(secrets['armor_api_key'], secrets['armor_api_secret'], sandbox)
  end

  def create_account(opts = {})
    data = @client.accounts.create({
      "company" => opts['company'],
      "user_name" => opts['user_name'],
      "user_email" => opts['user_email'],
      "user_phone" => opts['user_phone'],
    })
    if data[:status] == 200
      @account = data[:body]['account_id']
    end
  end

  def get_user(account)
    data = client.users(account).all.data[:body].first
    if data
      @user = data['user_id']
    end
  end

  def update_user(opts = {})
    result = @client.users(opts['account'].to_s).update(opts['user'].to_s,  {"user_name" => opts['user_name'], "user_phone" => opts['user_phone']})
  end

  def update_company(opts = {})
    #result = @client.accounts.update('11' , {:company => opts['company'].to_s})
  end

  def update_address(opts = {})
    result = @client.accounts.update(opts['account'].to_s, 
      {
        "address"=> opts['address'],
        "city" => opts['city'],
        "state" => opts['state'],
        "postal_code" => opts['postal_code'],
        "country" => opts['country']
      }
    )
  end

  def create_order(opts = {})
    result = client.orders(opts['account'].to_s).create(
              "seller_id" => opts['seller_id'], 
              "buyer_id" => opts['buyer_id'], 
              "amount" => opts['amount'], 
              "summary" => opts['summary'], 
              "description" => opts['description'], 
              "invoice_no" => opts['invoice_no'], 
              "po_no" => opts['po_no'], 
              "message" => opts['message']
      )
    if result.data[:status] == 200
      @order = result.data[:body]
    end
  end

  def get_paymentinstructions
    data = client.orders(account).paymentinstructions(order).all
  end

  def create_armor_bank_account(opts = {})
    result = client.accounts.bankaccounts(opts['account'].to_s).create(
      "type" => opts['account_type'], 
      "location" => opts['account_location'], 
      "bank" => opts['account_bank'], 
      "routing" => opts['account_routing'], 
      "swift" => opts['account_swift'], 
      "account" => opts['account_account'], 
      "iban" => opts['account_iban']
    )
    if result.data[:status] == 200
      result.data[:body]
    end
  end

  def get_order_status(opts = {})
    result = client.orders(opts['account'].to_s).get(opts['order_id'].to_s)
    if result.data[:status] == 200
      @order = result.data[:body]['status']
    end
  end
end

class ArmorService
  class BadResponseError < StandardError
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
        raise ArmorService::BadResponseError.new(response.body)
      end
      response
    end
  end
end