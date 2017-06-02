module Services
  module FlyAndBuy

    class CompanyDocument < Base
      attr_reader :user, :address, :synapse_pay

      def initialize(user, fly_buy_profile, address_id)
        @user = user
        @address = Address.where(id: address_id).first
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)

        super(nil, fly_buy_profile)
      end

      def submit
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        create_or_update_base_document(synapse_user)

        update_fly_buy_profile(synapse_company_doc_id: synapse_company_doc_id)
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: e.response['error'])
      end

      private

      def create_or_update_base_document(synapse_user)
        remove_base_document(synapse_user) if fly_buy_profile.synapse_company_doc_id.present?

        synapse_user = reload_synapse_user
        synapse_user.create_base_document(payload)
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
          physical_documents: [
            SynapsePayRest::PhysicalDocument.create(
              type: SynapsePay::DOC_TYPES[:ein],
              value: encode_attachment(file_tempfile: fly_buy_profile.eic_attachment.url, file_type: fly_buy_profile.eic_attachment_content_type)
            ),
            SynapsePayRest::PhysicalDocument.create(
              type: SynapsePay::DOC_TYPES[:bank_statement],
              value: encode_attachment(file_tempfile: fly_buy_profile.bank_statement.url, file_type: fly_buy_profile.bank_statement_content_type)
            )
          ],
          virtual_documents: [
            SynapsePayRest::VirtualDocument.create(
              type: SynapsePay::DOC_TYPES[:tin],
              value: fly_buy_profile.tin_number
            )
          ]
        }
      end

      def company_name
        "#{user.name} (#{user.company})"
      end

      def remove_base_document(synapse_user)
        base_document = SynapsePayRest::BaseDocument.new(user: synapse_user, id: fly_buy_profile.synapse_company_doc_id)
        base_document.update(permission_scope: 'DELETE_DOCUMENT')
      rescue SynapsePayRest::Error::NotFound
      end

      def synapse_company_doc_id
        synapse_user = reload_synapse_user
        base_document = synapse_user.base_documents.find { |doc| doc.name == company_name }
        base_document.present? ? base_document.id : nil
      end

      def reload_synapse_user
        synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
      end
    end
  end
end
