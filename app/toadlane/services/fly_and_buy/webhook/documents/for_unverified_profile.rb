module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class ForUnverifiedProfile < Documents::Base
          DOC_STATUS = ['SUBMITTED|VALID', 'SUBMITTED|INVALID'].freeze

          attr_reader :doc_status, :documents

          def initialize(fly_buy_profile, doc_status={}, documents=[])
            @doc_status = doc_status
            @documents = documents

            super(fly_buy_profile)
          end

          def process
            documents.each do |document|
              update_fly_buy_doc_status(document)

              document['virtual_docs'].each do |virtual_document|
                case virtual_document['status']
                when 'SUBMITTED|INVALID'
                  invalid_virtual_document(virtual_document)
                when 'SUBMITTED|MFA_PENDING'
                  invalid_kba_questions_submitted(virtual_document)
                else
                  notify_the_user(method_name: :send_account_not_verified_yet_notification_to_user)
                end
              end if valid_doc_status?
            end
          end

          private

          def valid_doc_status?
            DOC_STATUS.include?(doc_status['physical_doc']) && DOC_STATUS.include?(doc_status['virtual_doc'])
          end

          def invalid_kba_questions_submitted(document)
            update_fly_buy_profile(
              permission_scope_verified: false,
              kba_questions: document,
              completed: false
            )

            case document['document_type']
            when 'TIN'
              notify_the_user(method_name: :send_tin_num_partially_valid_notification_to_user)
            when 'SSN'
              notify_the_user(method_name: :send_ssn_num_partially_valid_notification_to_user)
            end
          end

          def invalid_virtual_document(document)
            data = {
              permission_scope_verified: false,
              kba_questions: {},
              completed: false
            }

            case document['document_type']
            when 'TIN'
              data.merge!(error_details: { "en": "Invalid field value supplied. #{fly_buy_profile.tin_number} is not a valid #{virtual_document['document_type'].downcase} number." })

              notify_the_user(method_name: :send_ein_num_not_valid_notification_to_user)
            when 'SSN'
              data.merge!(error_details: { "en": "Invalid field value supplied. #{fly_buy_profile.ssn_number} is not a valid #{virtual_document['document_type'].downcase} number." })

              notify_the_user(method_name: :send_ssn_num_not_valid_notification_to_user)
            end

            update_fly_buy_profile(data)
          end

          def update_fly_buy_doc_status(document)
            status = permission_scope(document)
            args = {}

            case document['id']
            when fly_buy_profile.synapse_company_doc_id
              args.merge!(company_doc_verified: status)
            when fly_buy_profile.synapse_user_doc_id
              args.merge!(user_doc_verified: status)
            end

            update_fly_buy_profile(args) if args.present?
          end

          def permission_scope(document)
            document['permission_scope'] == 'SEND|RECEIVE|1000000|DAILY'
          end
        end
      end
    end
  end
end
