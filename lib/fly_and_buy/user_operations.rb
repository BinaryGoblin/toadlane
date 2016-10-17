class FlyAndBuy::UserOperations

  attr_accessor :signed_in_user, :user_details, :client, :fly_buy_profile, :client_user

  # user => current user
  # user_details =>
  #   {"fingerprint"=>"6cc339e04458396d23af2b3cd30fa55c", "bank_name"=>"Triumph Bank",
  #       "address"=>"5699 Poplar Avenue", "name_on_account"=>"test neha",
  #       "account_num"=>"123456789", "routing_num"=>"064000020", "ip_address"=>"192.168.0.112",
  #       "ssn_number"=>"343434", "date_of_company(2i)"=>"9", "date_of_company(3i)"=>"30",
  #       "date_of_company(1i)"=>"2011", "eic_doc"=>#<ActionDispatch::Http::UploadedFile:0x000000024b9ab8
  # @content_type="text/csv",
  # @headers="Content-Disposition: form-data; name=\"fly_buy_profile[eic_doc]\"; filename=\"contact.csv\"\r\nContent-Type: text/csv\r\n",
  # @original_filename="contact.csv",
  # @tempfile=#<File:/tmp/RackMultipart20160930-9112-e49c7e.csv>>}
  def initialize(user, user_details = {})
    @signed_in_user = user
    @user_details = user_details
    @client = FlyBuyService.get_client
  end

  def create_user
    synapsepay_create_user
  end

  private

  def synapsepay_create_user
    create_fly_buy_profile_with_fingerprint

    create_user_response = creating_user_synapse

    store_returned_id(create_user_response)
  end

  def creating_user_synapse
    url = "https://sandbox.synapsepay.com/api/v3/user/create"

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
        user_details["ip_address"]
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

  def create_fly_buy_profile_with_fingerprint
    fly_buy_profiles = FlyBuyProfile.where(user_id: signed_in_user.id)
    if fly_buy_profiles.present?
      fly_buy_profiles.each do |profile|
        profile.destroy
      end
    end
    @fly_buy_profile = FlyBuyProfile.create({
                            encrypted_fingerprint: "user_#{signed_in_user.id}" + "_" + user_details[:fingerprint],
                            user_id: signed_in_user.id,
                            synapse_ip_address: user_details["ip_address"]
                          })
  end

  def store_returned_id(response)
    fly_buy_profile.update_attribute(:synapse_user_id, response["user"]["_id"]["$oid"])
  end
end