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

        create_or_update_document(synapse_user)
      rescue SynapsePayRest::Error => e
        update_fly_buy_profile(error_details: e.response['error'])
      end

      private

      def create_or_update_document(synapse_user)
        document = create_or_update_base_document(synapse_user)

        if document.present?
          create_virtual_documents(document)
          create_physical_documents(document)

          update_fly_buy_profile(synapse_user_doc_id: document.id)
        end
      end

      def create_or_update_base_document(synapse_user)
        base_documents = synapse_user.base_documents

        if base_documents.present?
          base_document = base_documents.find { |doc| doc.id == fly_buy_profile.synapse_user_doc_id } if fly_buy_profile.synapse_user_doc_id.present?
          base_document = base_documents.find { |doc| doc.name == user_name } unless base_document.present?
          if base_document.present?
            base_document.update(payload)
          else
            synapse_user.create_base_document(payload)
          end
        else
          synapse_user.create_base_document(payload)
        end

        user_document
      end

      def create_physical_documents(document)
        gov_doc = SynapsePayRest::PhysicalDocument.create(
          type: SynapsePay::DOC_TYPES[:gov_id],
          value: encode_attachment(file_tempfile: fly_buy_profile.gov_id.url, file_type: fly_buy_profile.gov_id_content_type)
        )

        document.add_physical_documents(gov_doc)
      end

      def create_virtual_documents(document)
        virtual_doc = SynapsePayRest::VirtualDocument.create(
          type: SynapsePay::DOC_TYPES[:ssn],
          value: fly_buy_profile.ssn_number
        )

        document.add_virtual_documents(virtual_doc)
      end

      def user_document
        synapse_user = reload_synapse_user
        synapse_user.base_documents.find { |doc| doc.name == user_name }
      end

      def reload_synapse_user
        synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
      end

      def payload
        {
          email: formatted_email,
          phone_number: user.phone,
          ip: fly_buy_profile.synapse_ip_address,
          name: user_name,
          aka: user_name,
          entity_type: fly_buy_profile.gender,
          entity_scope: fly_buy_profile.entity_scope,
          birth_day: fly_buy_profile.dob.day,
          birth_month: fly_buy_profile.dob.month,
          birth_year: fly_buy_profile.dob.year,
          address_street: address.line1,
          address_city: address.city,
          address_subdivision: address.state,
          address_postal_code: address.zip,
          address_country_code: address.country
        }
      end

      def formatted_email
        splited_email = user.email.split('@')
        updated_email = "#{splited_email.first}+#{user.first_name}"
        "#{updated_email}@#{splited_email.last}"
      end

      def user_name
        user.name
      end
    end
  end
end
