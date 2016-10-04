class FlyAndBuy::AddingBankDetails

  attr_accessor :signed_in_user, :client, :fly_buy_profile, :client_user, :user_details

  SynapsePayNodeType = {
    wire: "WIRE-US",
    synapse_us: "SYNAPSE-US"
  }

  SynapsePayCurrency = "USD"

  SynapsePayDocType = {
    ssn: 'SSN',
    ein: 'GOVT_ID'
  }

  def initialize(user, fly_buy_profile, user_details = {})
    @signed_in_user = user
    @user_details = user_details
    @fly_buy_profile = fly_buy_profile
    @client = FlyBuyService.get_client
  end

  def add_details
    add_doc_to_user_process
  end

  private
  def add_doc_to_user_process
    update_fly_buy_profile_with_attachment

    get_user_and_instantiate_user

    doc_response = add_necessary_doc

    if doc_response["error"].present?
      return doc_response
    end

    add_bank_acc_response  = create_bank_account
    store_returned_node_id(add_bank_acc_response)
  end

  def update_fly_buy_profile_with_attachment
    fly_buy_profile.update_attributes({
                            eic_attachment_file_name: user_details["eic_attachment"].original_filename,
                            eic_attachment_content_type: user_details["eic_attachment"].content_type,
                            eic_attachment_updated_at: DateTime.now
                          })
  end

  def get_user_and_instantiate_user
    user_response = client.users.get(user_id: fly_buy_profile.synapse_user_id)

    client_user = FlyBuyService.get_user(
                      oauth_key: nil,
                      fingerprint: fly_buy_profile.encrypted_fingerprint,
                      ip_address: fly_buy_profile.synapse_ip_address,
                      user_id: fly_buy_profile.synapse_user_id
                  )

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => fly_buy_profile.encrypted_fingerprint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    @client_user =  FlyBuyService.get_user(
                      oauth_key: oauth_response["oauth_key"],
                      fingerprint: fly_buy_profile.encrypted_fingerprint,
                      ip_address: fly_buy_profile.synapse_ip_address,
                      user_id: fly_buy_profile.synapse_user_id
                  )
  end

  def add_necessary_doc
    add_documents_payload = {
      'documents' => [{
        'email' => signed_in_user.email,
        'phone_number' => signed_in_user.phone,
        'ip' => fly_buy_profile.synapse_ip_address,
        'name' => signed_in_user.name,
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
          # 'document_value' => encode_attachment(file_tempfile: user_details["eic_attachment"].tempfile, file_type: user_details["eic_attachment"].content_type),
          'document_type' => SynapsePayDocType[:ein]
        }]
      }]
    }

    response = client_user.users.update(payload: add_documents_payload)

    if response["documents"].present? && response["documents"][0].present?
      fly_buy_profile.update_attribute(:synapse_document_id, response["documents"][0]["id"])
    else
      return response
    end
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

  def store_returned_node_id(response)
    if response["success"] == true
      fly_buy_profile.update_attribute(:synapse_node_id, response["nodes"][0]["_id"])
    end
  end

  def encode_attachment(file_tempfile:, file_type:)
    file_contents = open(file_tempfile) { |f| f.read }
    encoded = Base64.encode64(file_contents)
    mime_padding = "data:#{file_type};base64,"
    mime_padding + encoded
  end
end