class FlyAndBuy::AddingBankDetails

  attr_accessor :signed_in_user, :client, :fly_buy_profile, :client_user, :user_details,
                  :company_address

  SynapsePayNodeType = {
    wire: "WIRE-US",
    synapse_us: "SYNAPSE-US"
  }

  SynapsePayCurrency = "USD"

  SynapsePayDocType = {
    ssn: 'SSN',
    ein: 'EIN_DOC',
    bank_statement: 'PROOF_OF_ACCOUNT',
    gov_id: 'GOVT_ID',
    tin: 'TIN'
  }

  def initialize(user, fly_buy_profile, user_details = {})
    @signed_in_user = user
    @user_details = user_details
    @fly_buy_profile = fly_buy_profile
    @company_address = signed_in_user.addresses.company_address
    @client = FlyBuyService.get_client
  end

  def add_details
    add_doc_to_user_process
  end

  private
  def add_doc_to_user_process
    update_fly_buy_profile_with_attachment

    get_user_and_instantiate_user

    add_doc_response = add_necessary_doc
    add_bank_acc_response  = create_bank_account

    store_returned_node_id(add_bank_acc_response)
  rescue SynapsePayRest::Error::Conflict => e
    return e
  end

  def update_fly_buy_profile_with_attachment
    only_attachments = user_details.except(:fingerprint, :bank_name, :address, :name_on_account,
                              :account_num, :routing_num, :ssn_number, :ip_address,
                              "date_of_company(2i)", "date_of_company(3i)",
                              "date_of_company(1i)", :terms_of_service, :addresses,
                              :o_entity_type, :o_entity_scope, "dob(3i)",
                              "dob(2i)", "dob(1i)", :company_email, :company_phone,
                              :entity_type, :entity_scope, :tin_number)
    fly_buy_profile.update(only_attachments)
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
    # doc #1 for company
    add_documents_payload_1 = {
      'documents' => [{
        'email' => user_details["company_email"],
        'phone_number' => user_details["company_phone"],
        'ip' => fly_buy_profile.synapse_ip_address,
        'name' => signed_in_user.company,
        'alias' => signed_in_user.company,
        'entity_type' => user_details["entity_type"].upcase,
        'entity_scope' => user_details["entity_scope"].titleize,
        'day' => user_details["date_of_company(3i)"].to_i,
        'month' => user_details["date_of_company(2i)"].to_i,
        'year' => user_details["date_of_company(1i)"].to_i,
        'address_street' => company_address.first.line1,
        'address_city' => company_address.first.city,
        'address_subdivision' => company_address.first.state,
        'address_postal_code' => company_address.first.zip,
        'address_country_code' => company_address.first.country,
        'virtual_docs' => [
        {
          'document_value' => user_details["tin_number"],
          'document_type' => SynapsePayDocType[:tin]
        }],
        'physical_docs' => [{
          # This is EIN document
          'document_value' => encode_attachment(file_tempfile: fly_buy_profile.eic_attachment.url, file_type: fly_buy_profile.eic_attachment_content_type),
          'document_type' => SynapsePayDocType[:ein]
        },
        {
          # this is for bank statement
          'document_value': encode_attachment(file_tempfile: fly_buy_profile.bank_statement.url, file_type: fly_buy_profile.bank_statement_content_type),
          'document_type': SynapsePayDocType[:bank_statement]
        }]
      }]
    }

    company_doc_response = client_user.users.update(payload: add_documents_payload_1)

    # doc #2 for officer of company
    add_documents_payload_2 = {
      'documents' => [{
        'email' => signed_in_user.email,
        'phone_number' => signed_in_user.phone,
        'ip' => fly_buy_profile.synapse_ip_address,
        'name' => signed_in_user.name,
        'alias' => signed_in_user.name,
        'entity_type' => user_details["o_entity_type"].upcase,
        'entity_scope' => user_details["o_entity_scope"].titleize,
        'day' => user_details["dob(3i)"].to_i,
        'month' => user_details["dob(2i)"].to_i,
        'year' => user_details["dob(1i)"].to_i,
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
          # this is for gov_id
          'document_value': encode_attachment(file_tempfile: fly_buy_profile.gov_id.url, file_type: fly_buy_profile.gov_id_content_type),
          'document_type': SynapsePayDocType[:gov_id]
        }
      ]
      }]
    }

    user_doc_response = client_user.users.update(payload: add_documents_payload_2)

    if user_doc_response["documents"].present? && user_doc_response["documents"][0].present?
      fly_buy_profile.update_attribute(:synapse_document_id, user_doc_response["documents"][0]["id"])
      if user_doc_response["documents"][0]["virtual_docs"][0].present? && user_doc_response["documents"][1]["virtual_docs"][0]["document_type"] == "SSN" && user_doc_response["documents"][1]["virtual_docs"][0]["status"] == "SUBMITTED|MFA_PENDING"
        questions = user_doc_response["documents"][1]["virtual_docs"][0]["meta"]
        fly_buy_profile.update_attribute(:kba_questions, questions)
      end
      if user_doc_response["permission"].present? && user_doc_response["permission"] == "SEND-AND-RECEIVE"
        permission_array = user_doc_response["permission"].split("-")
        if permission_array.include?("SEND") && permission_array.include?("RECEIVE")
          fly_buy_profile.update_attribute(:permission_scope_verified, true)
        end
      end
    else
      return user_doc_response
    end
  rescue SynapsePayRest::Error::Conflict => e
    return e
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