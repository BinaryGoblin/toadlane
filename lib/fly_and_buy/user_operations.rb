class FlyAndBuy::UserOperations

  attr_accessor :user, :user_details, :client, :fly_buy_profile

  FingerPrintMessage = "fingerprint"

  SynapsePayNodeType = "WIRE-US"

  # user => current user
  # user_details =>
  #   {"fingerprint"=>"6cc339e04458396d23af2b3cd30fa55c", "bank_name"=>"Triumph Bank",
  #       "address"=>"5699 Poplar Avenue", "name_on_account"=>"test neha",
  #       "account_num"=>"123456789", "routing_num"=>"064000020", "ip_address"=>"192.168.0.112"}
  def initialize(user, user_details = {})
    @user = user
    @user_details = user_details
    @client = FlyBuyService.get_client
  end

  def create_user
    synapsepay_create_user
  end

  private

  def synapsepay_create_user
    create_fly_buy_profile_with_fingerprint

    create_user_response = client.users.create(
      name: user.name,
      email: user.email,
      phone: user.phone,
      fingerprint: fly_buy_profile.encrypted_fingerprint
    )

    user_client = authenticate_user(create_user_response)

    add_doc_response = add_necessary_doc(user_client)

    store_returned_id(add_doc_response)

    create_bank_account(create_user_response, user_client)
  end

  def create_fly_buy_profile_with_fingerprint
    encrypted_fingerprint = AESCrypt.encrypt(user_details[:fingerprint], FingerPrintMessage)
    FlyBuyProfile.create({
      encrypted_fingerprint: "user_#{user.id}" + "_" + user_details[:fingerprint],
      user_id: user.id
    })
    @fly_buy_profile = user.fly_buy_profile
  end

  def authenticate_user(create_user_response)
    client.users.authenticate_as(
                          id: create_user_response[:_id],
                          refresh_token: create_user_response[:refresh_token],
                          fingerprint: fly_buy_profile.encrypted_fingerprint
                        )
  end

  def add_necessary_doc(user_client)
    user_client.add_document(
        birthdate: Date.parse('1970/3/14'),
        first_name: user.first_name,
        last_name: user.last_name,
        street: user.addresses.first.line1,
        postal_code: user.addresses.first.zip,
        country_code: user.addresses.first.country,
        document_type: 'SSN',
        document_value: '2222'
      )
  end

  def create_bank_account(create_user_response, user_client)
    node = SynapsePayments::Nodes.new(
                                      client,
                                      create_user_response[:_id],
                                      user_client.oauth_key,
                                      fly_buy_profile.encrypted_fingerprint
                                      )

    data = {
      "type": SynapsePayNodeType,
      "info": {
        "nickname": user.name,
        "name_on_account": user_details["name_on_account"],
        "account_num": user_details["account_num"],
        "routing_num": user_details["routing_num"],
        "bank_name": user_details["bank_name"],
        "address": user_details["address"],
      }
    }

    result = node.create(data)

    if result[:success] == true
      store_returned_node_id(result)
    end
  end

  def store_returned_id(response)
    fly_buy_profile.update_attribute(:synapse_user_id, response[:_id])
  end

  def store_returned_node_id(response)
    fly_buy_profile.update_attribute(:synapse_node_id, response[:nodes][0][:_id])
  end
end