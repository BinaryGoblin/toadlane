module Services
  module FlyAndBuy
    module Webhook
      module Documents

        class Base

          attr_reader :fly_buy_profile

          def initialize(fly_buy_profile)
            @fly_buy_profile = fly_buy_profile
          end

          protected

          def update_fly_buy_profile(**options)
            fly_buy_profile.update_attributes(options)
          end

          def notify_the_user(method_name:)
            UserMailer.send(method_name, fly_buy_profile).deliver_later
          end

          def permission_scope(document)
            permission_arry = document['permission_scope'].split('|')
            permission_arry.include?('SEND') && permission_arry.include?('RECEIVE') && permission_arry.include?('DAILY')
          end

          def sub_documents_have_reviewing_status?(sub_documents)
            status = false

            sub_documents.each do |document|
              status = true if is_in_reviewing_status?(document)
            end

            status
          end

          def is_in_reviewing_status?(document)
            document['status'] == 'SUBMITTED|REVIEWING'
          end
        end
      end
    end
  end
end
