module Services
  module FlyAndBuy

    class UserDocument < Base
      attr_reader :user, :address, :synapse_pay

      def initialize(user, fly_buy_profile, address_id)
        @user = user
        @address = Address.where(id: address_id).first
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)

        super(nil, fly_buy_profile)
      end

      def submit
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        user_document = create_or_update_base_document(synapse_user)

        update_fly_buy_profile(synapse_user_doc_id: user_document.id) unless fly_buy_profile.synapse_user_doc_id.present?
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: e.response['error'])
      end

      private

      def create_or_update_base_document(synapse_user)
        if fly_buy_profile.synapse_user_doc_id.present?
          base_document = SynapsePayRest::BaseDocument.new(user: synapse_user, id: fly_buy_profile.synapse_user_doc_id)
          base_document.update(payload)
        else
          synapse_user.create_base_document(payload)
        end
      end

      def payload
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
          virtual_documents: [
            SynapsePayRest::VirtualDocument.create(
              type: SynapsePay::DOC_TYPES[:ssn],
              value: fly_buy_profile.ssn_number
            )
          ],
          physical_documents: [
            SynapsePayRest::PhysicalDocument.create(
              type: SynapsePay::DOC_TYPES[:gov_id],
              value: encode_attachment(file_tempfile: fly_buy_profile.gov_id.url, file_type: fly_buy_profile.gov_id_content_type)
            )
          ]
        }
      end

      def formatted_email
        splited_email = user.email.split('@')
        updated_email = "#{splited_email.first}+#{user.first_name}"
        "#{updated_email}@#{splited_email.last}"
      end
    end
  end
end
