module PromiseOrdersHelper
  def get_seller_charged_fee(order)
    number_with_precision(order.transaction_fee_amount + order.fraud_protection_fee_amount +
                        order.end_user_support_fee_amount, :precision => 2)
  end

  def get_order_amount_for_seller(order)
    seller_charged_fee = get_seller_charged_fee(order).to_f
    order.amount - seller_charged_fee
  end
end
