module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class ForUnverifiedProfile < Base
          DOC_STATUS = ['SUBMITTED|VALID', 'SUBMITTED|INVALID'].freeze

          attr_reader :doc_status, :options

          def initialize(fly_buy_profile, doc_status={}, options=[])
            @doc_status = doc_status
            @options = options

            super(fly_buy_profile)
          end

          def process
            options.each do |document|
              document['virtual_docs'].each do |virtual_document|
                case virtual_document['status']
                when 'SUBMITTED|INVALID'
                  invalid_virtual_document(virtual_document)
                when 'SUBMITTED|MFA_PENDING'
                  invalid_kba_questions_submitted(virtual_document)
                else
                  notify_the_user(method_name: :send_account_not_verified_yet_notification_to_user)
                end
              end
            end if valid_doc_status?
          end

          private

          def valid_doc_status?
            DOC_STATUS.include?(doc_status['physical_doc']) && DOC_STATUS.include?(doc_status['virtual_doc'])
          end

          def invalid_kba_questions_submitted(virtual_document)
            update_fly_buy_profile(
              permission_scope_verified: false,
              kba_questions: virtual_document,
              completed: false
            )

            case virtual_document['document_type']
            when 'TIN'
              notify_the_user(method_name: :send_tin_num_partially_valid_notification_to_user)
            when 'SSN'
              notify_the_user(method_name: :send_ssn_num_partially_valid_notification_to_user)
            end
          end

          def invalid_virtual_document(virtual_document)
            data = {
              permission_scope_verified: false,
              kba_questions: {},
              completed: false
            }

            case virtual_document['document_type']
            when 'TIN'
              data.merge!(error_details: { "en": "Invalid field value supplied. #{fly_buy_profile.tin_number} is not a valid #{virtual_document['document_type'].downcase} number." })

              notify_the_user(method_name: :send_ein_num_not_valid_notification_to_user)
            when 'SSN'
              data.merge!(error_details: { "en": "Invalid field value supplied. #{fly_buy_profile.ssn_number} is not a valid #{virtual_document['document_type'].downcase} number." })

              notify_the_user(method_name: :send_ssn_num_not_valid_notification_to_user)
            end

            update_fly_buy_profile(data)
          end
        end

      end
    end
  end
end
