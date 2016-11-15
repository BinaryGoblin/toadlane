class FlyAndBuy::UserOperations

  attr_accessor :signed_in_user, :user_details, :client, :fly_buy_profile,
                :client_user

  # user => current user
  def initialize(user, fly_buy_profile)
    @signed_in_user = user
    @client = FlyBuyService.get_client
    @fly_buy_profile = fly_buy_profile
  end

  def create_user
    synapsepay_create_user
  end

  private

  def synapsepay_create_user
    FlyBuyService.create_subscription
    
    create_user_response = creating_user_synapse

    store_returned_id(create_user_response)
  end

  def creating_user_synapse
    if Rails.env.production?
      url = ENV['SYNAPSEPAY_DASHBOARD_URL']
    else
      url = Rails.application.secrets['SYNAPSEPAY_DASHBOARD_URL']
    end

    create_payload = {
      "client": {
        "client_id": client.client.config["client_id"],  
        "client_secret": client.client.config["client_secret"]
      },
      "logins": [
        {
          "email": signed_in_user.email
        }
      ],
      "phone_numbers": [
        signed_in_user.phone
      ],
      "legal_names": [
        signed_in_user.name
      ],
      "fingerprints": [
        {
          "fingerprint": fly_buy_profile.encrypted_fingerprint
        }
      ],
      "ips": [
        fly_buy_profile.synapse_ip_address
      ],
      "extra": {
        "note": "Create User #{signed_in_user.id} #{signed_in_user.name}",
        "is_business": true
      }
    }

    response = RestClient.post(url, 
      create_payload.to_json,
      :content_type => :json,
      :accept => :json)

    JSON.parse(response)
  end

  def store_returned_id(response)
    fly_buy_profile.update_attribute(:synapse_user_id, response["user"]["_id"]["$oid"])
  end
end