module Services
  module FlyAndBuy
    module Webhook

      class TransactionsResponse

        attr_reader :options

        def initialize(options={})
          @options = options
        end

        def handle
          fly_buy_order, synapse_transaction_id, additional_seller_fee_transaction = parse_fly_buy_order_and_seller_fee_transaction

          case recent_status
          when 'SETTLED'
            Transactions::SettledTransactions.new(
              fly_buy_order: fly_buy_order,
              additional_seller_fee_transaction: additional_seller_fee_transaction,
              synapse_transaction_id: synapse_transaction_id,
              note: transaction_note
            ).process
          when 'QUEUED-BY-SYNAPSE'
            Transactions::QueuedTransactions.new(fly_buy_order).process
          end
        end

        private

        def recent_status
          options['recent_status']['status']
        end

        def parse_fly_buy_order_and_seller_fee_transaction
          case transaction_note
          when 'Transaction Created'
            synapse_transaction_id = options['_id']['$oid']

            [FlyBuyOrder.where(synapse_transaction_id: synapse_transaction_id).first, synapse_transaction_id, nil]
          when 'Released Payment'
            synapse_transaction_id = options['_id']['$oid']
            fly_buy_order_id = options['extra']['supp_id'].split(':').last

            [FlyBuyOrder.where(id: fly_buy_order_id).first, synapse_transaction_id, nil]
          when 'Released Payment To Additional Seller'
            synapse_transaction_id = options['_id']['$oid']
            additional_seller_fee_transaction_id = options['extra']['supp_id'].split('-').last
            additional_seller_fee_transaction = AdditionalSellerFeeTransaction.where(id: additional_seller_fee_transaction_id).first
            
            [additional_seller_fee_transaction.fly_buy_order, synapse_transaction_id, additional_seller_fee_transaction]
          end
        end

        def transaction_note
          options['extra']['note']
        end
      end
    end
  end
end
