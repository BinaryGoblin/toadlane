module Services
  module FlyAndBuy
    module Webhook

      class DocumentsResponse

        attr_reader :fly_buy_profile, :permission, :options

        def initialize(synapse_user_id, permission, options=[])
          @fly_buy_profile = FlyBuyProfile.where(synapse_user_id: synapse_user_id).first
          @permission = permission
          @options = options
        end

        def handle
          if verified_user?
            Documents::ForVerifiedProfile.new(fly_buy_profile).process
          else
            Documents::ForUnverifiedProfile.new(fly_buy_profile, options).process
          end
        end

        private

        def verified_user?
          permission == 'SEND-AND-RECEIVE'
        end
      end
    end
  end
end
