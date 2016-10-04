class FlyBuyOrdersController < ApplicationController
  #  creating order
  # # and making payment
  def place_order
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = fly_buy_order.product

    if current_user.fly_buy_profile_exist?
      create_transaction_response = create_transaction_in_synapsepay(fly_buy_order, product)

      if create_transaction_response["recent_status"]["note"] == "Transaction created"
        fly_buy_order.update_attributes({
            synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
            synapse_transaction_id: create_transaction_response["_id"],
            status: 'placed'
          })

        product.sold_out += fly_buy_order.count
        product.save

        send_email_notification(fly_buy_order)

        redirect_to dashboard_order_path(
          fly_buy_order,
          type: 'fly_buy'
        ), notice: 'Your order was successfully placed.'
      end
    else
      if fly_buy_order.update_attribute(:status, 'processing')
        product.sold_out += fly_buy_order.count
        product.save
        # email notification to buyer with order invoice and add bank account detail notificaiton

        # send_email_notification(fly_buy_order)

        flash[:notice] = 'Your order was successfully placed.'
      else
        flash[:notice] = 'Your order could not be placed.'
      end
      redirect_to product_checkout_path(
        product_id: product.id,
        fly_buy_order_id: fly_buy_order.id
      )
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

    user_response = client.users.get(user_id: FlyBuyProfile::AppUserId)

    client_user = FlyBuyService.get_user(oauth_key: nil, fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: current_user.fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => FlyBuyProfile::AppFingerPrint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    client_user = FlyBuyService.get_user(oauth_key: oauth_response["oauth_key"], fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: current_user.fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

    trans_payload = {
      "to" => {
        "type" => FlyAndBuy::UserOperations::SynapsePayNodeType[:wire],
        "id" => seller_fly_buy_profile.synapse_node_id
      },
      "from" => {
        "type" => FlyAndBuy::UserOperations::SynapsePayNodeType[:synapse_us],
        "id" => FlyBuyProfile::EscrowNodeID
      },
      "amount" => {
        "amount" => fly_buy_order.total,
        "currency" => FlyAndBuy::UserOperations::SynapsePayCurrency
      },
      "extra" => {
        "note" => "#{current_user.name} Sent to #{fly_buy_order.buyer.name} account",
        "webhook" => "http://requestb.in/q283sdq2",
        "process_on" => 1,
        "ip" => current_user.fly_buy_profile.synapse_ip_address
      },
      # "fees" => [{
      #   "fee" => 1.00,
      #   "note" => "Facilitator Fee",
      #   "to" => {
      #     "id" => "55d9287486c27365fe3776fb"
      #   }
      # }]
    }

    create_transaction_response = client_user.trans.create(node_id: FlyBuyProfile::EscrowNodeID, payload: trans_payload)

    if create_transaction_response["error"]["en"] == "You do not have sufficient balance for this transfer."
      flash[:alert] = "The funds are not yet received in escrow. Please wait"
    else
      fly_buy_order.update_attributes({
        payment_release: true,
        status: 'completed'
      })
      UserMailer.send_payment_released_notification_to_seller(fly_buy_order).deliver_later
      flash[:alert] = "Payment has been successfully released to seller."
    end
    redirect_to dashboard_orders_path
  rescue SynapsePayments::Error => e
    redirect_to dashboard_orders_path, :flash => { :error => e.message }
  end

  def confirm_order_placed
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = fly_buy_order.product

    fly_buy_params.merge!(ip_address: '192.168.0.112')
    FlyAndBuy::UserOperations.new(current_user, fly_buy_params).create_user

    create_transaction_response = create_transaction_in_synapsepay(fly_buy_order, product)
    

    if create_transaction_response["recent_status"]["note"] == "Transaction created"
      fly_buy_order.update_attributes({
          synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
          synapse_transaction_id: create_transaction_response["_id"],
          status: 'placed'
        })

      product.sold_out += fly_buy_order.count
      product.save

      send_email_notification(fly_buy_order)

      redirect_to dashboard_order_path(
          fly_buy_order,
          type: 'fly_buy'
        ), notice: 'Your order has been confirmed.'
    end
  end

  private
  def fly_buy_params
    params.require(:fly_buy_profile).permit!
  end

  def send_email_notification(fly_buy_order)
    UserMailer.sales_order_notification_to_seller(fly_buy_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(fly_buy_order).deliver_later
  end

  def encode_attachment(file_tempfile:, file_type:)
    file_contents = IO.read(file_tempfile)
    encoded = Base64.encode64(file_contents)
    mime_padding = "data:#{file_type};base64,"
    mime_padding + encoded
  end

  def convert_invoice_to_image(fly_buy_order)
    html = render_to_string(
        {
            layout: 'layouts/print.html.slim',
            file: Rails.root + '/app/views/shared/_invoice.html.slim',
            locals: {order: fly_buy_order}
        })
    kit = IMGKit.new(html)
    img = kit.to_png
    file  = Tempfile.new(["template_#{fly_buy_order.synapse_transaction_id}", 'png'], 'tmp',
                         :encoding => 'ascii-8bit')
    file.write(img)

    file
  end

  def create_transaction_in_synapsepay(fly_buy_order, product)
    file = convert_invoice_to_image(fly_buy_order)

    fly_buy_profile = FlyBuyProfile.where(user_id: current_user.id).first

    client = FlyBuyService.get_client
    user_response = client.users.get(user_id: fly_buy_profile.synapse_user_id)

    client_user = FlyBuyService.get_user(oauth_key: nil, fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address, user_id: fly_buy_profile.synapse_user_id)

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => fly_buy_profile.encrypted_fingerprint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    client_user = FlyBuyService.get_user(oauth_key: oauth_response["oauth_key"], fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address, user_id: fly_buy_profile.synapse_user_id)

    trans_payload = {
      "to" => {
        "type" => FlyAndBuy::UserOperations::SynapsePayNodeType[:synapse_us],
        "id" => FlyBuyProfile::EscrowNodeID
      },
      "amount" => {
        "amount" => fly_buy_order.total,
        "currency" => FlyAndBuy::UserOperations::SynapsePayCurrency
      },
      "extra" => {
        "note" => "#{current_user.name} Deposit to #{FlyAndBuy::UserOperations::SynapsePayNodeType[:synapse_us]} account",
        "webhook" => "http://requestb.in/q283sdq2",
        "process_on" => 1,
        "ip" => fly_buy_profile.synapse_ip_address,
        "other" => {
          "attachments" => [
            encode_attachment(file_tempfile: file.path, file_type: 'image/png')
          ]
        }
      },
      # "fees" => [{
      #   "fee" => 1.00,
      #   "note" => "Facilitator Fee",
      #   "to" => {
      #     "id" => "55d9287486c27365fe3776fb"
      #   }
      # }]
    }

    client_user.trans.create(node_id: fly_buy_profile.synapse_node_id, payload: trans_payload)
  end
end
