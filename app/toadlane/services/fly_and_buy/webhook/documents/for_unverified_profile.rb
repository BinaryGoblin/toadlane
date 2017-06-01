module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class ForUnverifiedProfile < Documents::Base
          attr_reader :documents, :notification

          def initialize(fly_buy_profile, documents=[])
            @documents = documents
            @notification = find_or_create_fly_buy_profile_notification(fly_buy_profile)

            super(fly_buy_profile)
          end

          def process
            documents.each do |document|
              if permission_scope(document)
                update_doc_status(document, true) unless (sub_documents_have_reviewing_status?(document['virtual_docs']) || sub_documents_have_reviewing_status?(document['physical_docs']))
              else
                invalid_doc_permission(document)
              end
            end
          end

          private

          def invalid_doc_permission(document)
            document['physical_docs'].each do |physical_document|
              invalid_physical_document(physical_document) if invalid_doc_status?(physical_document)
            end

            document['virtual_docs'].each do |virtual_document|
              invalid_virtual_document(virtual_document) if invalid_doc_status?(virtual_document)

              mfa_pending_virtual_document(virtual_document) if mfa_pending_doc_status?(virtual_document)
            end

            update_doc_status(document, false)
          end

          def mfa_pending_virtual_document(document)
            case document['document_type']
            when 'TIN'
              unless notification.mfa_pending_tin?
                notify_the_user(method_name: :send_tin_num_partially_valid_notification_to_user)
                notification.update_attribute(:mfa_pending_tin, true)
              end
            when 'SSN'
              unless notification.mfa_pending_ssn?
                notify_the_user(method_name: :send_ssn_num_partially_valid_notification_to_user)
                notification.update_attribute(:mfa_pending_ssn, true)
              end
            end
            #notify_the_user(method_name: :send_account_not_verified_yet_notification_to_user)

            update_fly_buy_profile(kba_questions: document)
          end

          def invalid_virtual_document(document)
            data = {}

            case document['document_type']
            when 'TIN'
              data[:error_details] = { 'en': "Invalid field value supplied. #{fly_buy_profile.tin_number} is not a valid EIN number." }

              unless notification.invalid_tin?
                notify_the_user(method_name: :send_ein_num_not_valid_notification_to_user)
                notification.update_attribute(:invalid_tin, true)
              end
            when 'SSN'
              data[:error_details] = { 'en': "Invalid field value supplied. #{fly_buy_profile.ssn_number} is not a valid SSN number." }

              unless notification.invalid_ssn?
                notify_the_user(method_name: :send_ssn_num_not_valid_notification_to_user)
                notification.update_attribute(:invalid_ssn, true)
              end
            end

            update_fly_buy_profile(data)
          end

          def invalid_physical_document(document)
            data = {}

            case document['document_type']
            when 'EIN_DOC'
              data[:error_details] = { 'en': 'Invalid EIN DOCUMENT uploaded. Please upload valid document.' }
            when 'PROOF_OF_ACCOUNT'
              data[:error_details] = { 'en': 'Invalid BANK STATEMENT uploaded. Please upload valid document.' }
            when 'GOVT_ID'
              data[:error_details] = { 'en': 'Invalid GOVERNMENT ISSUED ID uploaded. Please upload valid document.' }
            end

            update_fly_buy_profile(data)
          end

          def update_doc_status(document, status)
            args = {}

            case document['id']
            when fly_buy_profile.synapse_company_doc_id
              args[:company_doc_verified] = status
            when fly_buy_profile.synapse_user_doc_id
              args[:user_doc_verified] = status
            end

            update_fly_buy_profile(args) if args.present?
          end

          def invalid_doc_status?(document)
            document['status'] == 'SUBMITTED|INVALID'
          end

          def mfa_pending_doc_status?(document)
            document['status'] == 'SUBMITTED|MFA_PENDING'
          end

          def find_or_create_fly_buy_profile_notification(fly_buy_profile)
            if fly_buy_profile.fly_buy_profile_notification.present?
              fly_buy_profile.fly_buy_profile_notification
            else
              FlyBuyProfileNotification.create(fly_buy_profile_id: fly_buy_profile.id)
            end
          end
        end
      end
    end
  end
end
