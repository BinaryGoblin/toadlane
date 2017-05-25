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
          if verified_user?
            Documents::ForVerifiedProfile.new(fly_buy_profile, options['documents']).process
          else
            Documents::ForUnverifiedProfile.new(fly_buy_profile, options['doc_status'], options['documents']).process
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
      end
    end
  end
end
