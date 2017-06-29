module Services
  module FlyAndBuy
    module Webhook
      module Transactions

        class SettledTransactions < Transactions::Base

          attr_reader :additional_seller_fee_transaction, :synapse_transaction_id, :note

          def initialize(fly_buy_order:, additional_seller_fee_transaction:, synapse_transaction_id:, note:)
            @additional_seller_fee_transaction = additional_seller_fee_transaction
            @synapse_transaction_id = synapse_transaction_id
            @note = note

            super(fly_buy_order)
          end

          def process
            case note
            when 'Transaction Created'
              unless fly_buy_order.funds_in_escrow?
                status = (fly_buy_order.order_type == 'same_day') ? :placed : :pending_inspection
                update_fly_buy_order(status: status, funds_in_escrow: true, error_details: {})

                notify_the_user(method_name: :send_funds_received_notification_to_seller)
                notify_the_user(method_name: :send_transaction_settled_notification_to_buyer)
              end
            when 'Released Payment'
              unless fly_buy_order.payment_release?
                update_fly_buy_order(status: :completed, payment_release: true, error_details: {})

                notify_the_user(method_name: :send_payment_released_notification_to_seller)
              end
            when 'Released Payment To Additional Seller'
              unless fly_buy_order.payment_released_to_group?
                additional_seller_fee_transaction.update_attributes(
                  synapse_transaction_id: synapse_transaction_id,
                  is_paid: true
                )
                fly_buy_order.reload

                options = { status: :processing_fund_release_to_group, error_details: {} }
                unless fly_buy_order.additional_seller_fee_transactions.unpaid.present?
                  options.merge!(status: :payment_released_to_group, payment_released_to_group: true)
                end
                update_fly_buy_order(options)

                notify_the_user(method_name: :send_payment_release_to_additional_seller, extra_arg: additional_seller_fee_transaction.user)
              end
            when 'Transaction Refunded'
              update_fly_buy_order(status: :refunded, error_details: {})
              update_product_count
              notify_the_user(method_name: :send_transaction_refunded_notification_to_buyer)
            end
          end
        end

      end
    end
  end
end
