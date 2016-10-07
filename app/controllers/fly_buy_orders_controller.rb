class FlyBuyOrdersController < ApplicationController
  #  creating order
  # # and making payment
  def place_order
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = fly_buy_order.product
    seller_fee_percent, seller_fee_amount = get_seller_fees(fly_buy_order)

    if current_user.fly_buy_profile_exist?
      create_transaction_response = create_transaction_in_synapsepay(fly_buy_order, product)
      if create_transaction_response["recent_status"]["note"] == "Transaction created"
        fly_buy_order.update_attributes({
            synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
            synapse_transaction_id: create_transaction_response["_id"],
            status: 'pending_confirmation',
            seller_fees_amount: seller_fee_amount,
            seller_fees_percent: seller_fee_percent,
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
      fly_buy_params.merge!(ip_address: '192.168.0.112')
      FlyAndBuy::UserOperations.new(current_user, fly_buy_params).create_user

      if fly_buy_order.update_attribute(:status, 'processing')
        product.sold_out += fly_buy_order.count
        product.save
        # email notification to buyer with order invoice and add bank account detail notificaiton

        # send_email_notification(fly_buy_order)
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
    if fly_buy_order.update_attributes(inspection_complete: true, status: 'placed')
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

    seller_fee_percent, seller_fee_amount = get_seller_fees(fly_buy_order)

    trans_payload = {
      "to" => {
        "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:wire],
        "id" => seller_fly_buy_profile.synapse_node_id
      },
      "from" => {
        "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:synapse_us],
        "id" => FlyBuyProfile::EscrowNodeID
      },
      "amount" => {
        "amount" => fly_buy_order.total,
        "currency" => FlyAndBuy::AddingBankDetails::SynapsePayCurrency
      },
      "extra" => {
        "supp_id" => "#{fly_buy_order.id}",
        "note" => "#{current_user.name} Sent to #{fly_buy_order.buyer.name} account",
        "webhook" => "http://requestb.in/q283sdq2",
        "process_on" => 1,
        "ip" => current_user.fly_buy_profile.synapse_ip_address
      },
      "fees" => [{
        "fee" => seller_fee_percent,
        "note" => "Seller Fee",
        "to" => {
          "id" => seller_fly_buy_profile.synapse_node_id
        }
      }]
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

    seller_fee_percent, seller_fee_amount = get_seller_fees(fly_buy_order)

    FlyAndBuy::AddingBankDetails.new(current_user, current_user.fly_buy_profile, fly_buy_params).add_details

    create_transaction_response = create_transaction_in_synapsepay(fly_buy_order, product)
    
    if create_transaction_response["recent_status"]["note"] == "Transaction created"
      fly_buy_order.update_attributes({
          synapse_escrow_node_id: FlyBuyProfile::EscrowNodeID,
          synapse_transaction_id: create_transaction_response["_id"],
          status: 'pending_confirmation',
          seller_fees_amount: seller_fee_amount,
          seller_fees_percent: seller_fee_percent,
        })

      product.sold_out += fly_buy_order.count
      product.save

      send_email_notification(fly_buy_order)

      UserMailer.send_wire_instruction_notification_to_buyer(fly_buy_order).deliver_later
      UserMailer.wire_instruction_notification_sent_to_seller(fly_buy_order).deliver_later

      redirect_to dashboard_order_path(
          fly_buy_order,
          type: 'fly_buy'
        ), notice: 'You have been emailed wire instructions!'
    end
  end

  def resend_wire_instruction
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    UserMailer.send_wire_instruction_notification_to_buyer(fly_buy_order).deliver_later
    redirect_to dashboard_order_path(
      fly_buy_order,
      type: 'fly_buy'
    ), notice: 'You have been emailed wire instructions!'
  end

  def cancel_transaction
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])

    client = FlyBuyService.get_client

    seller_fly_buy_profile = fly_buy_order.seller.fly_buy_profile
    buyer_fly_buy_profile = fly_buy_order.buyer.fly_buy_profile

    user_response = client.users.get(user_id: FlyBuyProfile::AppUserId)

    client_user = FlyBuyService.get_user(oauth_key: nil, fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: current_user.fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => FlyBuyProfile::AppFingerPrint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    client_user = FlyBuyService.get_user(oauth_key: oauth_response["oauth_key"], fingerprint: FlyBuyProfile::AppFingerPrint, ip_address: current_user.fly_buy_profile.synapse_ip_address, user_id: FlyBuyProfile::AppUserId)

    cancel_transaction = client_user.trans.delete(
                          node_id: buyer_fly_buy_profile.synapse_node_id,
                          trans_id: fly_buy_order.synapse_transaction_id)
    binding.pry
    if cancel_transaction["recent_status"]["status"] == "CANCELED"
      fly_buy_order.update_attribute(:status, 'cancelled')
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
        "type" => FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:synapse_us],
        "id" => FlyBuyProfile::EscrowNodeID
      },
      "amount" => {
        "amount" => fly_buy_order.total,
        "currency" => FlyAndBuy::AddingBankDetails::SynapsePayCurrency
      },
      "extra" => {
        "supp_id" => "#{fly_buy_order.id}",
        "note" => "#{current_user.name} Deposit to #{FlyAndBuy::AddingBankDetails::SynapsePayNodeType[:synapse_us]} account",
        "webhook" => "http://requestb.in/q283sdq2",
        "process_on" => 0,
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

  def get_seller_fees(fly_buy_order)
    order_amount = fly_buy_order.total

    if order_amount < 1000000
      fee_percent = 1
      amount = order_amount * 1/100
    elsif order_amount >= 1000000
      fee_percent = 0.35
      amount = order_amount * 0.35/100
    end

    [fee_percent, amount]
  end
end


