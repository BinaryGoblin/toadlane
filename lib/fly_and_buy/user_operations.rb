class FlyAndBuy::UserOperations

  attr_accessor :signed_in_user, :user_details, :client, :fly_buy_profile,
                :client_user

  # user => current user
  # user_details =>
  #  {"fingerprint"=>"6cc339e04458396d23af2b3cd30fa55c",
  # "date_of_company(2i)"=>"1",
  # "date_of_company(3i)"=>"20",
  # "date_of_company(1i)"=>"1999",
  # "company_address"=>"dddd",
  # "entity_type"=>"Corp",
  # "entity_scope"=>"small business",
  # "address"=>"5699 Poplar Avenue",
  # "eic_attachment"=>
  #  #<ActionDispatch::Http::UploadedFile:0x007f6f55b971e0
  #   @content_type="image/jpeg",
  #   @headers=
  #    "Content-Disposition: form-data; name=\"fly_buy_profile[eic_attachment]\"; filename=\"synapse_test_image.jpg\"\r\nContent-Type: image/jpeg\r\n",
  #   @original_filename="synapse_test_image.jpg",
  #   @tempfile=#<File:/tmp/RackMultipart20161020-30151-17pois8.jpg>>,
  # "bank_statement"=>
  #  #<ActionDispatch::Http::UploadedFile:0x007f6f55b970f0
  #   @content_type="image/jpeg",
  #   @headers=
  #    "Content-Disposition: form-data; name=\"fly_buy_profile[bank_statement]\"; filename=\"synapse_test_image.jpg\"\r\nContent-Type: image/jpeg\r\n",
  #   @original_filename="synapse_test_image.jpg",
  #   @tempfile=#<File:/tmp/RackMultipart20161020-30151-th0z6o.jpg>>,
  # "dob(2i)"=>"1",
  # "dob(3i)"=>"20",
  # "dob(1i)"=>"1999",
  # "ssn_number"=>"2222",
  # "gov_id"=>
  #  #<ActionDispatch::Http::UploadedFile:0x007f6f55b96e98
  #   @content_type="image/jpeg",
  #   @headers=
  #    "Content-Disposition: form-data; name=\"fly_buy_profile[gov_id]\"; filename=\"synapse_test_image.jpg\"\r\nContent-Type: image/jpeg\r\n",
  #   @original_filename="synapse_test_image.jpg",
  #   @tempfile=#<File:/tmp/RackMultipart20161020-30151-10glwbk.jpg>>,
  # "bank_name"=>"Triumph Bank",
  # "name_on_account"=>"tes t14004",
  # "account_num"=>"123456789",
  # "routing_num"=>"064000020",
  # "terms_of_service"=>"1",
  # "ip_address"=>"127.0.0.1",
  # "address_id"=>"15"
  def initialize(user, fly_buy_profile, user_details = {})
    @signed_in_user = user
    @user_details = user_details
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

  def store_returned_id(response)
    fly_buy_profile.update_attribute(:synapse_user_id, response["user"]["_id"]["$oid"])
  end
end