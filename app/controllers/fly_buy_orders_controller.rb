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

    response = user_client.send_money(
      from: fly_buy_profile.synapse_node_id,
      to: FlyBuyProfile::EscrowNodeID,
      to_node_type: FlyAndBuy::UserOperations::SynapseEscrowNodeType,
      amount: fly_buy_order.total,
      currency: FlyAndBuy::UserOperations::SynapsePayCurrency,
      ip_address: fly_buy_profile.synapse_ip_address
    )

    if response[:recent_status][:note] == "Transaction created"
      fly_buy_order.update_attributes({
          synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
          synapse_transaction_id: response[:_id],
          funds_in_escrow: true,
          status: 'placed'
        })

      product.sold_out += fly_buy_order.count
      product.save

      redirect_to dashboard_order_path(
          fly_buy_order,
          type: 'fly_buy'
        ), notice: 'Your order was successfully placed.'
    end
  end

  def set_inspection_date
    product = Product.unexpired.find(params[:product_id])

    if current_user.profile_complete?
      inspection_date = DateTime.new(
        params["inspection_date"]["date(1i)"].to_i,
        params["inspection_date"]["date(2i)"].to_i,
        params["inspection_date"]["date(3i)"].to_i,
        params["inspection_date"]["date(4i)"].to_i,
        params["inspection_date"]["date(5i)"].to_i
      )

      # seller reject buyer added date and add new inspection date
      if params[:fly_buy_order_id].present?
        fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
        fly_buy_order.buyer_requested.update_attribute(:approved, false)
        fly_buy_order.inspection_dates.create!({
          date: inspection_date,
          creator_type: "seller",
          fly_buy_order_id: fly_buy_order.id
        })
      else
        # seller approve buyer added inspection date
        fly_buy_order = FlyBuyOrder.create!({
          buyer_id: current_user.id,
          seller_id: product.user.id,
          product_id: product.id
        })

        fly_buy_order.inspection_dates.create!({
          date: inspection_date,
          creator_type: "buyer",
          fly_buy_order_id: fly_buy_order.id
        })
      end

      if fly_buy_order.errors.any?
        redirect_to product_path(id: product.id, fly_buy_order_id: fly_buy_order.id), :flash => { :alert => fly_buy_order.errors.full_messages.first}
      else
        if product.user == current_user
          if fly_buy_order.inspection_date_rejected_by_seller.present?
            flash[:notice] = 'You have rejected requested inspection date and added a new one and notified the buyer.'
          else
            flash[:notice] = 'You have accepted requested inspection date and notified the buyer.'
          end
          UserMailer.send_inspection_date_set_notification_to_buyer(fly_buy_order).deliver_later
        else
          flash[:notice] = 'Your requested inspection date has been submitted. You will be notified when the seller responds.'
          UserMailer.send_inspection_date_set_notification_to_seller(fly_buy_order).deliver_later
        end
        redirect_to product_path(id: product.id, fly_buy_order_id: fly_buy_order.id)
      end
    else
      redirect_to product_path(id: product.id), :flash => { :error => "You must complete your profile to view Fly & Buy inspection dates." }
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.message.split(": ")[1]
    if params[:fly_buy_order_id].present?
      redirect_to product_path(id: product.id, fly_buy_order_id: fly_buy_order.id, buyer_request_inspection_date: true), :flash => { :alert => @errors}
    else
      redirect_to product_path(id: product.id, fly_buy_order_id: fly_buy_order.id), :flash => { :alert => @errors}
    end
  end

  def confirm_inspection_date_by_seller
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = Product.unexpired.find(params[:product_id])

    if fly_buy_order.inspection_dates.buyer_added.last.update_attributes({approved: true})
      UserMailer.send_inspection_date_confirm_notification_to_buyer(fly_buy_order).deliver_later
      redirect_to product_path(id: product.id, fly_buy_order_id: fly_buy_order.id), :flash => { :notice => "Inspection date has been set to #{fly_buy_order.inspection_dates.buyer_added.last.get_inspection_date}."}
    else
      redirect_to product_path(id: product.id, fly_buy_order_id: fly_buy_order.id)
    end
  end

  def complete_inspection
    fly_buy_order = FlyBuyOrder.find_by_id(params["fly_buy_order_id"])
    if fly_buy_order.update_attribute(:inspection_complete, true)
      flash[:notice] = 'Order has been marked as inspected'
    else
      flash[:alert] = 'Could not be marked as inspected'
    end
    redirect_to dashboard_orders_path
  end

  def release_payment
    fly_buy_order = FlyBuyOrder.find_by_id(params["fly_buy_order_id"])

    client = FlyBuyService.get_client

    seller_fly_buy_profile = fly_buy_order.seller.fly_buy_profile

    app_fingerprint = ""

    url = "https://sandbox.synapsepay.com/api/v3/user/signin"
    a = {
      "client": {
        "client_id": "id-fb13c910-a846-49e0-a479-26e763bfc62b",
        "client_secret": "secret-b703ba44-2bac-49c6-85f5-3de140742041"
      },
      "login":{
        "email": "neha@jyaasa.com",
        "password": "TestTest123$"
      },
      "user":{
        "_id":{
          "$oid": FlyBuyProfile::AppUserId
        },
        "fingerprint":FlyBuyProfile::AppFingerPrint,
        "ip":"192.168.0.112"
      }
    }
    b = RestClient.post(url,
      a.to_json,
      :content_type => :json,
      :accept => :json)

    o = JSON.parse(b)

    s = SynapsePayments::Transactions.new(
                        client,
                        o["user"]["_id"]["$oid"],
                        FlyBuyProfile::EscrowNodeID,
                        o["oauth"]["oauth_key"],
                        FlyBuyProfile::AppFingerPrint
                      )

    data = {
      node_id: seller_fly_buy_profile.synapse_node_id,
      node_type: FlyAndBuy::UserOperations::SynapsePayNodeType,
      amount: fly_buy_order.total,
      currency: FlyAndBuy::UserOperations::SynapsePayCurrency,
      ip_address: current_user.fly_buy_profile.synapse_ip_address
    }

    u = s.create(data)

    redirect_to dashboard_orders_path, :flash => { :notice => 'Payment has been successfully released to seller.'}
  rescue SynapsePayments::Error => e
    redirect_to dashboard_orders_path, :flash => { :error => e.message }
  end

  private
  def fly_buy_params
    params.require(:fly_buy_profile).permit!
  end
end
