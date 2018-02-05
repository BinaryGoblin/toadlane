module Services
  module FlyAndBuy
    module Webhook

      class DocumentsResponse

        attr_reader :fly_buy_profile, :options

        def initialize(options={})
          @options = options
          @fly_buy_profile = FlyBuyProfile.where(synapse_user_id: synapse_user_id).first          
        end

        def handle
          if verified_user? && added_correct_documents? && !unverified_documents_present?
            Documents::ForVerifiedProfile.new(fly_buy_profile, options['documents']).process
          else
            Documents::ForUnverifiedProfile.new(fly_buy_profile, options['documents']).process
          end
        end

        private

        def verified_user?
          permission == 'SEND-AND-RECEIVE'
        end

        def synapse_user_id
          options['_id']['$oid']
        end

        def permission
          options['permission']
        end

        def added_correct_documents?
          case fly_buy_profile.profile_type
          when 'tier_1'
            options['documents'].length == 1
          else
            options['documents'].length == 2
          end
        end

        def unverified_documents_present?
          options['documents'].select { |doc| doc['permission_scope'] == 'UNVERIFIED' }.present?
        end
      end
    end
  end
end
