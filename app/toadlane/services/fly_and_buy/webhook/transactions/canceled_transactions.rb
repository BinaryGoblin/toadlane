module Services
  module FlyAndBuy
    module Webhook
      module Transactions

        class CanceledTransactions < Transactions::Base
          attr_reader :additional_seller_fee_transaction, :error_note, :note

          def initialize(fly_buy_order:, additional_seller_fee_transaction:, error_note:, note:)
            @additional_seller_fee_transaction = additional_seller_fee_transaction
            @note = note

            super(fly_buy_order)
          end

          def process
            case note
            when 'Transaction Created'
              update_fly_buy_order(status: :cancelled, funds_in_escrow: false, error_details: error_description)
              update_product_count

              notify_the_user(method_name: :notify_buyer_for_cancled_order)

              fly_buy_order.reload
              Services::ActivityTracker.track(fly_buy_order.buyer, fly_buy_order)
            when 'Released Payment'
              update_fly_buy_order(status: :placed, payment_release: false, error_details: error_description)

              notify_the_user(method_name: :notify_buyer_for_cancled_seller_payment)
            when 'Released Payment To Additional Seller'
              update_fly_buy_order(status: :completed, payment_released_to_group: false, error_details: error_description)

              notify_the_user(method_name: :notify_seller_for_cancled_additional_seller_payment, extra_arg: additional_seller_fee_transaction.user)
            end
          end

          private

          def error_description
            error = {}
            error.merge('en': error_note) if error_note.present?
            error
          end
        end
      end
    end
  end
end
