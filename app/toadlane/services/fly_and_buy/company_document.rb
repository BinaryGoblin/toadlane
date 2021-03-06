module Services
  module FlyAndBuy

    class CompanyDocument < Base
      attr_reader :user, :address, :synapse_pay

      def initialize(user, fly_buy_profile, address_id)
        @user = user
        @address = Address.where(id: address_id).first
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address, dynamic_fingerprint: fly_buy_profile.is_old_profile?)

        super(nil, fly_buy_profile)
      end

      def submit
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        document = create_or_update_document(synapse_user)

        if document.present?
          update_fly_buy_profile(synapse_company_doc_id: document.id)
        else
          update_fly_buy_profile(error_details: { en: 'Please enter valid information to verify your fly buy account.' })
        end
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: get_error_details(e.response))
      end

      private

      def create_or_update_document(synapse_user)
        base_documents = synapse_user.base_documents

        if base_documents.present?
          base_document = base_documents.find { |doc| doc.id == fly_buy_profile.synapse_company_doc_id } if fly_buy_profile.synapse_company_doc_id.present?
          base_document = base_documents.find { |doc| doc.name == company_name } unless base_document.present?

          if base_document.present?
            base_document.update(payload)
          else
            synapse_user.create_base_document(payload)
          end
        else
          synapse_user.create_base_document(payload)
        end

        company_document
      end

      def company_document
        synapse_user = reload_synapse_user

        synapse_user.base_documents.find { |doc| doc.name == company_name }
      end

      def reload_synapse_user
        synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
      end

      def payload
        {
          email: user.email,
          phone_number: user.phone,
          ip: fly_buy_profile.synapse_ip_address,
          name: company_name,
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
          physical_documents: payload_for_physical_documents,
          virtual_documents: payload_for_virtual_documents
        }
      end

      def payload_for_physical_documents
        physical_documents = []

        physical_documents << SynapsePayRest::PhysicalDocument.create(
          type: SynapsePay::DOC_TYPES[:ein],
          value: encode_attachment(file_tempfile: fly_buy_profile.eic_attachment.url, file_type: fly_buy_profile.eic_attachment_content_type)
        )

        case fly_buy_profile.profile_type
        when 'tier_2'
          physical_documents << SynapsePayRest::PhysicalDocument.create(
            type: SynapsePay::DOC_TYPES[:address_proof],
            value: encode_attachment(file_tempfile: fly_buy_profile.bank_statement.url, file_type: fly_buy_profile.bank_statement_content_type)
          )
        when 'tier_3'
          physical_documents << SynapsePayRest::PhysicalDocument.create(
            type: SynapsePay::DOC_TYPES[:bank_statement],
            value: encode_attachment(file_tempfile: fly_buy_profile.bank_statement.url, file_type: fly_buy_profile.bank_statement_content_type)
          )
        end

        physical_documents
      end

      def payload_for_virtual_documents
        [SynapsePayRest::VirtualDocument.create(
          type: SynapsePay::DOC_TYPES[:tin],
          value: fly_buy_profile.tin_number
        )]
      end

      def company_name
        "#{user.name.strip} (#{user.company.strip})"
      end
    end
  end
end
