module Services
  module FlyAndBuy
    module Webhook

      class Responses

        attr_reader :options

        def initialize(options={})
          @options = options
        end

        def handle
          DocumentsResponse.new(options).handle if response_for_document?
          NodeResponse.new(options).handle if response_for_node?
          TransactionsResponse.new(options).handle if response_for_transaction?
        end

        private

        def response_for_document?
          options['documents'].present?
        end

        def response_for_node?
          options['info'].present? && options['allowed'].present? && options['user_id'].present? && options['is_active'].present?
        end

        def response_for_transaction?
          options['fees'].present? && options['amount'].present?
        end
      end
    end
  end
end
