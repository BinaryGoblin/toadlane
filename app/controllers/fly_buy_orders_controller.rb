class FlyBuyOrdersController < ApplicationController
  #  creating order
  # # and making payment
  def place_order
    binding.pry
    # fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    # product = fly_buy_order.product
    # set_promise_pay_instance
    # if current_user.promise_account.nil?
    #   create_bank_account
    #   create_item_in_promise(product, fly_buy_order)
    # else
    #   create_item_in_promise(product, fly_buy_order)
    # end
  # rescue Promisepay::UnprocessableEntity => e
  #   flash[:error] = e.message
  #   redirect_to product_checkout_path(
  #     product_id: product.id,
  #     fly_buy_order_id: fly_buy_order.id
  #   )
  end

  private
  def set_promise_pay_instance
    promise_pay_instance = PromisePayService.new
    @client = promise_pay_instance.client
  end
end
