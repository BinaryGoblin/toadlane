class FlyAndBuy::UserOperations

  attr_accessor :user, :user_details, :client

  # user => current user
  # user_details => {:fingerprint=>"6cc339e04458396d23af2b3cd30fa55c", :ip_address=>"192.168.0.112"}
  def initialize(user, user_details = {})
    @user = user
    @user_details = user_details
    @client = FlyBuyService.get_client
  end

  def create_user
    # create_payload
    arko_method
  end

  private

  def arko_method
    response = client.users.create(
      name: user.name,
      email: user.email,
      phone: user.phone,
      fingerprint: user_details[:fingerprint]
    )

    user_client = client.users.authenticate_as(
                      id: response[:_id],
                      refresh_token: response[:refresh_token],
                      fingerprint: user_details[:fingerprint])

    response = user_client.add_document(
        birthdate: Date.parse('1970/3/14'),
        first_name: user.first_name,
        last_name: user.last_name,
        street: user.addresses.first.line1,
        postal_code: user.addresses.first.zip,
        country_code: user.addresses.first.country,
        document_type: 'SSN',
        document_value: '2222'
      )

    store_returned_id(response)

  end

  # def create_payload
  #   payload = {
  #       "logins" =>  [
  #           {
  #               "email" =>  user.email
  #           }
  #       ],
  #       "phone_numbers" =>  [
  #           user.phone
  #       ],
  #       "legal_names" =>  [
  #           user.name
  #       ],
  #       "extra" =>  {
  #           "supp_id" =>  generate_sup_id,
  #           "is_business" =>  is_business?
  #       },
  #   }
  #   binding.pry
  #   create_response = client.users.create(payload: payload)

  #   update_payload = {
  #       "refresh_token" => create_response["refresh_token"],
  #       "update" => {
  #           "login" => {
  #               "email" => user.email
  #           },
  #           "phone_number" => user.phone,
  #           "legal_name" => user.name
  #       }
  #   }

  #   update = client.users.update(payload: update_payload)

  #   oauth_payload = {
  #       "refresh_token" =>  create_response["refresh_token"]
  #   }
  #   oauth_response = client.users.refresh(payload: oauth_payload)

  #   acct_rout_payload = {
  #       "type" => "ACH-US",
  #       "info" => {
  #           "nickname" => "Ruby Library Savings Account",
  #           "name_on_account" => user_details["name_on_account"],
  #           "account_num" => user_details["account_num"],
  #           "routing_num" => user_details["routing_num"],
  #           "type" => user_details["account_type"],
  #           "class" => user_details["holder_type"]
  #       },
  #       "extra" => {
  #           "supp_id" => generate_sup_id
  #       }
  #   }

  #   acct_rout_response = client.nodes.add(payload: acct_rout_payload)
  # end

  def create_bank_account

  end

  def store_returned_id(response)
    FlyBuyProfile.create({
      synapse_user_id: response[:_id],
      user_id: user.id
      })
  end

  def generate_sup_id
    if Rails.env.development?
      'dev_' + user.id.to_s
    elsif Rails.env.staging?
      'stag_' + user.id.to_s
    else
      user.id
    end
  end

  def is_business?
    user_details["holder_type"] == "business"
  end
end