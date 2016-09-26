class FlyBuyOrdersController < ApplicationController
  #  creating order
  # # and making payment
  def place_order
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = fly_buy_order.product

    if current_user.fly_buy_profile.nil?
      fly_buy_params.merge!(ip_address: '192.168.0.112')
      FlyAndBuy::UserOperations.new(current_user, fly_buy_params).create_user
    end
    fly_buy_profile = FlyBuyProfile.where(user_id: current_user.id).first

    seller_profile = fly_buy_order.seller.fly_buy_profile

    @client = FlyBuyService.get_client

    user = @client.users.find(fly_buy_profile.synapse_user_id)

    user_client = @client.users.authenticate_as(
                          id: fly_buy_profile.synapse_user_id,
                          refresh_token: user[:refresh_token],
                          fingerprint: fly_buy_profile.encrypted_fingerprint
                        )
    nodes = user_client.nodes(fly_buy_profile.synapse_node_id)
    # here node_id and node_type is of buyer's node_id and node_type
    response = nodes.transactions.create(
                                node_id: FlyBuyProfile::EscrowNodeID,
                                node_type: FlyAndBuy::UserOperations::SynapseEscrowNodeType,
                                amount: fly_buy_order.total,
                                currency: FlyAndBuy::UserOperations::SynapsePayCurrency,
                                ip_address: fly_buy_profile.synapse_ip_address
                              )

    if response[:_id].present?
      fly_buy_profile.update_attributes({
          synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
          synapse_transaction_id: response[:_id]
        })
    end



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

  def set_inspection_date
  end

  def confirm_inspection_date_by_seller
  end

  def complete_inspection
  end

  private
  def fly_buy_params
    params.require(:fly_buy_profile).permit!
  end
end
