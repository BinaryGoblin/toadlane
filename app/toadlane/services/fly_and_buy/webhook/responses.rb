module Services
  module FlyAndBuy
    module Webhook

      class Responses

        attr_reader :options

        def initialize(options={})
          @options = options
        end

        def handle
          Services::FlyAndBuy::Webhook::DocumentsResponse.new(params['_id']['$oid'], options['permission'], options['documents']) if response_for_document?

          Services::FlyAndBuy::Webhook::TransactionsResponse.new(options) if response_for_transaction?
        end

        private

        def response_for_document?
          options['documents'].present?
        end

        def response_for_transaction?
          options['fees'].present? && options['amount'].present?
        end
      end
    end
  end
end
