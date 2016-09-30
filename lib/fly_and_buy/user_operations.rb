class FlyAndBuy::UserOperations

  attr_accessor :signed_in_user, :user_details, :client, :fly_buy_profile, :client_user

  FingerPrintMessage = "fingerprint"

  SynapsePayNodeType = {
    wire: "WIRE-US",
    synapse_us: "SYNAPSE-US"
  }

  SynapsePayCurrency = "USD"

  SynapsePayDocType = {
    ssn: 'SSN',
    ein: 'GOVT_ID'
  }

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

    instantiate_user(create_user_response)

    add_doc_response = add_necessary_doc(create_user_response)

    add_bank_acc_response  = create_bank_account
    store_returned_node_id(add_bank_acc_response)
  end

  def instantiate_user(response)
    ip_address = fly_buy_profile.synapse_ip_address
    user_id = fly_buy_profile.synapse_user_id
    fingerprint = fly_buy_profile.encrypted_fingerprint
    oauth_key = response["oauth"]["oauth_key"]

    @client_user = FlyBuyService.get_user(oauth_key: oauth_key, fingerprint: fingerprint, ip_address: ip_address, user_id: user_id)
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
    @fly_buy_profile = FlyBuyProfile.create({
                            encrypted_fingerprint: "user_#{signed_in_user.id}" + "_" + user_details[:fingerprint],
                            user_id: signed_in_user.id,
                            synapse_ip_address: user_details["ip_address"]
                          })
  end

  def authenticate_user(create_user_response)
    oauth_payload = {
      "refresh_token" => create_user_response["user"]["refresh_token"]
    }

    client.users.refresh(payload: oauth_payload)
  end

  def add_necessary_doc(response)
    url = "https://sandbox.synapsepay.com/api/v3/user/docs/add"
    ein_doc = Roo::CSV.new(user_details["eic_doc"].original_filename)

    add_documents_payload = {
      'documents' => [{
        'email' => signed_in_user.email,
        'phone_number' => signed_in_user.phone,
        'ip' => fly_buy_profile.synapse_ip_address,
        'name' => 'tedt test',
        'alias' => signed_in_user.name,
        'entity_type' => 'CORP',
        'entity_scope' => 'Small Business',
        'day' => user_details["date_of_company(3i)"].to_i,
        'month' => user_details["date_of_company(2i)"].to_i,
        'year' => user_details["date_of_company(1i)"].to_i,
        'address_street' => signed_in_user.addresses.first.line1,
        'address_city' => signed_in_user.addresses.first.city,
        'address_subdivision' => signed_in_user.addresses.first.state,
        'address_postal_code' => signed_in_user.addresses.first.zip,
        'address_country_code' => signed_in_user.addresses.first.country,
        'virtual_docs' => [{
          'document_value' => user_details["ssn_number"],
          'document_type' => SynapsePayDocType[:ssn]
        }],
        'physical_docs' => [{
          'document_value' => "data:text/csv;base64,SUQsTmFtZSxUb3RhbCAoaW4gJCksRmVlIChpbiAkKSxOb3RlLFRyYW5zYWN0aW9uIFR5cGUsRGF0ZSxTdGF0dXMNCjUxMTksW0RlbW9dIEJlbHogRW50ZXJwcmlzZXMsLTAuMTAsMC4wMCwsQmFuayBBY2NvdW50LDE0MzMxNjMwNTEsU2V0dGxlZA0KNTExOCxbRGVtb10gQmVseiBFbnRlcnByaXNlcywtMS4wMCwwLjAwLCxCYW5rIEFjY291bnQsMTQzMzE2MjkxOSxTZXR0bGVkDQo1MTE3LFtEZW1vXSBCZWx6IEVudGVycHJpc2VzLC0xLjAwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDMzMTYyODI4LFNldHRsZWQNCjUxMTYsW0RlbW9dIEJlbHogRW50ZXJwcmlzZXMsLTEuMDAsMC4wMCwsQmFuayBBY2NvdW50LDE0MzMxNjI2MzQsU2V0dGxlZA0KNTExNSxbRGVtb10gQmVseiBFbnRlcnByaXNlcywtMS4wMCwwLjAwLCxCYW5rIEFjY291bnQsMTQzMzE2MjQ5OCxTZXR0bGVkDQo0ODk1LFtEZW1vXSBMRURJQyBBY2NvdW50LC03LjAwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDMyMjUwNTYyLFNldHRsZWQNCjQ4MTIsS2FyZW4gUGF1bCwtMC4xMCwwLjAwLCxCYW5rIEFjY291bnQsMTQzMTk5NDAzNixTZXR0bGVkDQo0NzgwLFNhbmthZXQgUGF0aGFrLC0wLjEwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDMxODQ5NDgxLFNldHRsZWQNCjQzMTUsU2Fua2FldCBQYXRoYWssLTAuMTAsMC4wMCwsQmFuayBBY2NvdW50LDE0Mjk3NzU5MzcsU2V0dGxlZA0KNDMxNCxTYW5rYWV0IFBhdGhhaywtMC4xMCwwLjAwLCxCYW5rIEFjY291bnQsMTQyOTc3NTQzNCxTZXR0bGVkDQo0MzEzLFNhbmthZXQgUGF0aGFrLC0wLjEwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDI5Nzc1MzY0LFNldHRsZWQNCjQzMTIsU2Fua2FldCBQYXRoYWssLTAuMTAsMC4wMCwsQmFuayBBY2NvdW50LDE0Mjk3NzUyNTAsU2V0dGxlZA0KNDMxMSxTYW5rYWV0IFBhdGhhaywtMC4xMCwwLjAwLCxCYW5rIEFjY291bnQsMTQyOTc3NTAxMyxTZXR0bGVkDQo0MjM1LFtEZW1vXSBCZWx6IEVudGVycHJpc2VzLC0wLjEwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDI5MzMxODA2LFNldHRsZWQNCjQxMzYsU2Fua2FldCBQYXRoYWssLTAuMTAsMC4wMCwsQmFuayBBY2NvdW50LDE0Mjg4OTA4NjMsU2V0dGxlZA0KNDAzMCxTYW5rYWV0IFBhdGhhaywtMC4xMCwwLjAwLCxCYW5rIEFjY291bnQsMTQyODIxNTM5NixTZXR0bGVkDQo0MDE0LFtEZW1vXSBCZWx6IEVudGVycHJpc2VzLC0wLjEwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDI4MTI1MzgwLENhbmNsZWQNCjM4MzIsU2Fua2FldCBQYXRoYWssLTAuMTAsMC4wMCwsQmFuayBBY2NvdW50LDE0MjcxMDc0NzAsU2V0dGxlZA0KMzgyNixTYW5rYWV0IFBhdGhhaywtMC4xMCwwLjAwLCxCYW5rIEFjY291bnQsMTQyNzAzNTM5MixTZXR0bGVkDQozODI1LFNhbmthZXQgUGF0aGFrLC0wLjEwLDAuMDAsLEJhbmsgQWNjb3VudCwxNDI3MDMyOTM3LFNldHRsZWQNCg==",
          'document_type' => SynapsePayDocType[:ein]
        }]
      }]
    }

    client_user.users.update(payload: add_documents_payload)
  end

  def create_bank_account
    acct_rout_payload = {
      "type" => SynapsePayNodeType[:wire],
      "info" => {
        "nickname" => signed_in_user.name + "WIRE-US",
        "name_on_account" => user_details["name_on_account"],
        "account_num" => user_details["account_num"],
        "routing_num" => user_details["routing_num"],
        "bank_name" => user_details["bank_name"],
        "address" => user_details["address"]
      }
    }
   
    client_user.nodes.add(payload: acct_rout_payload)
  end

  def store_returned_id(response)
    fly_buy_profile.update_attribute(:synapse_user_id, response["user"]["_id"]["$oid"])
  end

  def store_returned_node_id(response)
    if response["success"] == true
      fly_buy_profile.update_attribute(:synapse_node_id, response["nodes"][0]["_id"])
    end
  end
end