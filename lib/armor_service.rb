class ArmorService
  require 'armor_payments'
  attr_accessor :client, :account, :user, :order
  
  def initialize()
    if Rails.env.production?
      @client = ArmorPayments::API.new '3e96f3cd9d27d471740124868ac7906d', '101a2b03f84a1cb16aa0fa3f22f9c3006af025198605876cf81735bbe1417536'
    else
      @client = ArmorPayments::API.new 'fac5d8a4eab1c348925a7a5421367d86', '6956753620b1cdecfbbcbe4a6f3287a4b748edc6b8eff1e8d8dbf23b679db8d5', sandbox=true
    end
  end

  def create_account(opts = {})
    data = @client.accounts.create({
      "company" => opts['company'],
      "user_name" => opts['user_name'],
      "user_email" => opts['user_email'],
      "user_phone" => opts['user_phone'],
      "user_password" => SecureRandom.hex(26),
      "confirmed"  => true
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

