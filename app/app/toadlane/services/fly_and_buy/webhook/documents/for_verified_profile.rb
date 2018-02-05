module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class ForVerifiedProfile < Documents::Base
          attr_reader :documents

          def initialize(fly_buy_profile, documents)
            @documents = documents

            super(fly_buy_profile)
          end

          def process
            unless documents_have_reviewing_status?
              already_verified = fly_buy_profile.permission_scope_verified?

              options = {}

              options.merge!(
                permission_scope_verified: true,
                kba_questions: {},
                completed: fly_buy_profile.bank_details_verified?
              )

              if fly_buy_profile.bank_details_verified?
                options.merge!(error_details: {})

                unless already_verified
                  Services::ActivityTracker.track(fly_buy_profile.user, fly_buy_profile)
                  notify_the_user(method_name: :send_account_verified_notification_to_user)
                end
              end

              documents.each do |document|
                options.merge!(get_fly_buy_doc_status(document))
              end

              update_fly_buy_profile(options)
            end
          end

          private

          def get_fly_buy_doc_status(document)
            status = permission_scope(document)
            args = {}

            case document['id']
            when fly_buy_profile.synapse_company_doc_id
              args.merge!(company_doc_verified: status)
            when fly_buy_profile.synapse_user_doc_id
              args.merge!(user_doc_verified: status)
            end

            args
          end

          def documents_have_reviewing_status?
            status = false

            documents.each do |document|
              status = true if sub_documents_have_reviewing_status?(document['virtual_docs']) || sub_documents_have_reviewing_status?(document['physical_docs'])
            end

            status
          end
        end
      end
    end
  end
end
