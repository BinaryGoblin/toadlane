module Services
  module FlyAndBuy

    class BankDetails < Base

      attr_accessor :user, :fly_buy_profile, :options, :address, :synapse_pay

      DOC_TYPES = {
        ssn: 'SSN',
        ein: 'EIN_DOC',
        bank_statement: 'PROOF_OF_ACCOUNT',
        gov_id: 'GOVT_ID',
        tin: 'TIN',
        business_documents: 'OTHER'
      }.freeze

      def initialize(user, fly_buy_profile, options = {})
        @user = user
        @fly_buy_profile = fly_buy_profile
        @options = options
        @address = Address.where(id: options[:address_id]).first

        @synapse_pay = Services::SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)
      end

      def add
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)

        company_document = synapse_user.create_base_document(payload_for_company)
        synapse_user = company_document.user

        user_document = synapse_user.create_base_document(payload_for_user)
        synapse_user = user_document.user

        update_fly_buy_profile(synapse_document_id: user_document.id)

        create_bank_account(synapse_user)
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: e.response['error'])
      end

      private

      def payload_for_company
        {
          email: user.email,
          phone_number: user.phone,
          ip: fly_buy_profile.synapse_ip_address,
          name: [user.first_name, user.company].join(' '),
          aka: user.company,
          entity_type: fly_buy_profile.entity_type,
          entity_scope: fly_buy_profile.entity_scope,
          birth_day: fly_buy_profile.date_of_company.day,
          birth_month: fly_buy_profile.date_of_company.month,
          birth_year: fly_buy_profile.date_of_company.year,
          address_street: address.line1,
          address_city: address.city,
          address_subdivision: address.state,
          address_postal_code: address.zip,
          address_country_code: address.country,
          physical_documents: [
            SynapsePayRest::PhysicalDocument.create(
              type: DOC_TYPES[:ein],
              value: encode_attachment(file_tempfile: fly_buy_profile.eic_attachment.url, file_type: fly_buy_profile.eic_attachment_content_type)
            ),
            SynapsePayRest::PhysicalDocument.create(
              type: DOC_TYPES[:bank_statement],
              value: encode_attachment(file_tempfile: fly_buy_profile.bank_statement.url, file_type: fly_buy_profile.bank_statement_content_type)
            )
          ],
          virtual_documents: [
            SynapsePayRest::VirtualDocument.create(
              type: DOC_TYPES[:tin],
              value: fly_buy_profile.tin_number
            )
          ]
        }
      end

      def payload_for_user
        physical_documents = [
          SynapsePayRest::PhysicalDocument.create(
            type: DOC_TYPES[:gov_id],
            value: encode_attachment(file_tempfile: fly_buy_profile.gov_id.url, file_type: fly_buy_profile.gov_id_content_type)
          )
        ]

        physical_documents.push(
          SynapsePayRest::PhysicalDocument.create(
            type: DOC_TYPES[:business_documents],
            value: encode_attachment(file_tempfile: fly_buy_profile.business_documents.url, file_type: fly_buy_profile.business_documents_content_type)
          )
        ) if fly_buy_profile.business_documents.present?

        {
          email: formatted_email,
          phone_number: user.phone,
          ip: fly_buy_profile.synapse_ip_address,
          name: user.name,
          aka: user.name,
          entity_type: fly_buy_profile.entity_type,
          entity_scope: fly_buy_profile.entity_scope,
          birth_day: fly_buy_profile.dob.day,
          birth_month: fly_buy_profile.dob.month,
          birth_year: fly_buy_profile.dob.year,
          address_street: address.line1,
          address_city: address.city,
          address_subdivision: address.state,
          address_postal_code: address.zip,
          address_country_code: address.country,
          physical_documents: physical_documents,
          virtual_documents: [
            SynapsePayRest::VirtualDocument.create(
              type: DOC_TYPES[:ssn],
              value: fly_buy_profile.ssn_number
            )
          ]
        }
      end

      def create_bank_account(synapse_user)
        account_info = {
          bank_name:        options[:bank_name],
          account_number:   options[:account_num],
          routing_number:   options[:routing_num],
          name_on_account:  options[:name_on_account],
          address:          options[:address]
        }
        account_info.merge!(swift: options[:swift]) if options[:swift].present?
       
        bank_details = if fly_buy_profile.outside_the_us?
          account_info.merge!(nickname: "#{user.name} (WIRE-INT)")

          synapse_user.create_wire_int_node(account_info)
        else
          account_info.merge!(nickname: "#{user.name} (WIRE-US)")

          synapse_user.create_wire_us_node(account_info)
        end

        save_node_details(bank_details)
      rescue SynapsePayRest::Error => e
        UserMailer.send_routing_number_incorrect_notification(user).deliver_later if e.response['error']['en'].present? && e.response['error']['en'].include?('routing_num')
        update_fly_buy_profile(error_details: e.response['error'])
      end

      def save_node_details(bank_response)
        # Refresh user
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)

        update_fly_buy_profile(synapse_node_id: bank_response.id, error_details: {})

        fly_buy_profile_completed(synapse_pay: synapse_pay, fly_buy_profile: fly_buy_profile)
      end

      def formatted_email
        splited_email = user.email.split('@')
        updated_email = "#{splited_email.first}+#{user.first_name}"
        "#{updated_email}@#{splited_email.last}"
      end

      def update_fly_buy_profile(**options)
        fly_buy_profile.update_attributes(options)
      end
    end
  end
end
