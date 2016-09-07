class PromiseOrdersController < ApplicationController

  #  creating item i.e order in promise
  # # and making payment
  def place_order
    promise_order = PromiseOrder.find_by_id(params[:promise_order_id])
    product = promise_order.product
    set_promise_pay_instance
    if current_user.promise_account.nil?
      create_bank_account
      create_item_in_promise(product, promise_order)
    else
      create_item_in_promise(product, promise_order)
    end
  rescue Promisepay::UnprocessableEntity => e
    flash[:error] = e.message
    redirect_to product_checkout_path(
      product_id: product.id,
      promise_order_id: promise_order.id
    )
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

      if params[:promise_order_id].present?
        promise_order = PromiseOrder.find_by_id(params[:promise_order_id])
        product.inspection_dates.create!({
          date: inspection_date,
          creator_type: "seller",
          product_id: product.id
        })
        NotificationCreator.new(promise_order).seller_set_inspection_date_to_buyer
      else
        promise_order = PromiseOrder.create!({
          buyer_id: current_user.id,
          seller_id: product.user.id,
          product_id: product.id
        })

        promise_order.inspection_dates.create!({
          date: inspection_date,
          creator_type: "buyer",
          promise_order_id: promise_order.id
        })
        NotificationCreator.new(promise_order).buyer_request_inspection_date_to_seller
      end

      if promise_order.errors.any?
        redirect_to product_path(id: product.id, promise_order_id: promise_order.id), :flash => { :alert => promise_order.errors.full_messages.first}
      else
        if product.user == current_user
          UserMailer.send_inspection_date_set_notification_to_buyer(promise_order).deliver_later
        else
          UserMailer.send_inspection_date_set_notification_to_seller(promise_order).deliver_later
        end
        redirect_to product_path(id: product.id, promise_order_id: promise_order.id), :flash => { :notice => 'Your requested inspection date has been submitted. You will be notified when the seller responds.'}
      end
    else
      redirect_to product_path(id: product.id), :flash => { :error => "You must complete your profile to view Fly & Buy inspection dates." }
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.message.split(": ")[1]
    if params[:promise_order_id].present?
      redirect_to product_path(id: product.id, promise_order_id: promise_order.id, buyer_request_inspection_date: true), :flash => { :alert => @errors}
    else
      redirect_to product_path(id: product.id, promise_order_id: promise_order.id), :flash => { :alert => @errors}
    end
  end

  def refund
    set_promise_pay_instance
    promise_order = PromiseOrder.find_by_id(params['promise_order_id'])
    item = @client.items.find(promise_order.promise_item_id)
    amount_in_cent = (promise_order.amount * 100).to_i

    begin
      item.request_refund(
        id: promise_order.promise_item_id
      )

      item.refund(
        id: promise_order.promise_item_id
      )
    rescue Promisepay::UnprocessableEntity => e
      flash[:error] = "The order cannot be refunded, as the state of the order is #{item.state}"
      redirect_to dashboard_orders_path
    else
      promise_order.update_attributes({
                                        status: item.state,
                                        refunded: true})

      flash[:notice] = "Your order has been refunded."
      redirect_to dashboard_orders_path
    end
  end

  def confirm_inspection_date_by_seller
    promise_order = PromiseOrder.find_by_id(params[:promise_order_id])
    product = Product.unexpired.find(params[:product_id])

    if promise_order.inspection_dates.buyer_added.last.update_attributes({approved: true})
      UserMailer.send_inspection_date_confirm_notification_to_buyer(promise_order).deliver_later
      # NotificationCreator.new(promise_order).seller_confirm_date
      redirect_to product_path(id: product.id, promise_order_id: promise_order.id), :flash => { :notice => "Inspection date has been set to #{promise_order.inspection_dates.buyer_added.last.get_inspection_date}."}
    else
      redirect_to product_path(id: product.id, promise_order_id: promise_order.id)
    end
  end

  def callbacks
    render nothing: true, status: 200
  end

  def complete_inspection
    set_promise_pay_instance
    promise_order = PromiseOrder.find_by_id(params["promise_order_id"])
    item = @client.items.find(promise_order.promise_item_id)

    begin
      if item.state == "payment_deposited"
        request_release = item.request_release( id: promise_order.promise_item_id)
        item.release_payment( id: promise_order.promise_item_id) if request_release
      end
    rescue Promisepay::UnprocessableEntity => e
      promise_order.update_attributes(
        status: 'failed'
      )
      flash[:error] = e.message
    else
      promise_order.update_attributes(
        inspection_complete: true,
        payment_release: true,
        status: item.state
      )
      flash[:notice] = "Product has been marked as inspected and payment has been released."
    end
    redirect_to dashboard_orders_path
  end

  private
  def promise_params
    params.require(:promise_order).permit!
  end

  def set_promise_pay_instance
    promise_pay_instance = PromisePayService.new
    @client = promise_pay_instance.client
  end

  def create_item_in_promise(product, promise_order)
    amount_in_cent = promise_order.amount * 100

    item = @client.items.create(
      id: set_promise_order_id(promise_order),
      name: product.name,
      amount: amount_in_cent, #amount in cent
      payment_type: 1, # 1=> Escrow
      buyer_id: promise_order.buyer.id,
      seller_id: promise_order.seller.id,
      fee_ids: fees_ids_collection(promise_order),
      description: product.description
      # due_date: '22/04/2016' #not quite sure about this
    )

    if item.present? && item.status["state"] == "pending"
      item.request_payment(id: item.id)

      response = @client.direct_debit_authorities.create(
        account_id: promise_order.buyer_bank_id,
        amount: amount_in_cent
      )

      item.make_payment(
                        id: promise_order.promise_item_id,
                        account_id: promise_order.buyer_bank_id)

      if promise_order.update_attributes(
            {
              status: item.state,
              promise_item_id: item.id
            })

        product.sold_out += promise_order.count
        product.save

        send_email_and_create_notification(promise_order)

        redirect_to dashboard_order_path(
          promise_order,
          type: 'promise'
        ), notice: 'Your order was successfully placed.'
      else
        redirect_to product_checkout_path(
          product_id: product.id,
          promise_order_id: promise_order.id
        ), :flash => { :alert => promise_order.errors.messages}
      end
    else
      redirect_to product_checkout_path(
        product_id: product.id,
        promise_order_id: promise_order.id
      ), :flash => { :alert => 'Your order cannot be placed.'}
    end
  end

  def fees_ids_collection(promise_order)
    fee_id_collection = promise_order.promise_seller_fee_id
    if promise_order.amount >= 1000.00
      fee_id_collection[:ach_fee_capped] + ',' + fee_id_collection[:transaction_fee] +
      ',' + fee_id_collection[:end_user_fee] + ',' + fee_id_collection[:fraud_protection_fee]
    else
      fee_id_collection[:ach_fee] + ',' + fee_id_collection[:transaction_fee] +
        ',' + fee_id_collection[:end_user_fee] + ',' + fee_id_collection[:fraud_protection_fee]
    end
    # In promise we are saving fees in amount in cents even to percentage
    # # the fee_type_id distinguishes if the fee is fixed or percentage or others
    # # for details see https://reference.promisepay.com/#create-fee
  end

  def send_email_and_create_notification(promise_order)
    UserMailer.sales_order_notification_to_seller(promise_order).deliver_later
    UserMailer.sales_order_notification_to_buyer(promise_order).deliver_later
    NotificationCreator.new(promise_order).after_order_created
  end

  def create_bank_account
    address = current_user.addresses.first
    phone_number = Phonelib.parse(current_user.phone)
    country = IsoCountryCodes.find(address.country)

    all_user_ids = @client.users.find_all.map &:id

    if all_user_ids.include? current_user.id.to_s
      user = @client.users.find(current_user.id)
    else
      user = @client.users.create(
              id: current_user.id,
              first_name: current_user.first_name,
              last_name: current_user.last_name,
              email: current_user.email,
              company: current_user.company,
              mobile: phone_number.international,
              address: address.line1,
              city: address.city,
              state: address.state,
              zip: address.zip,
              country: country.alpha3
            )
    end

    country_for_bank = IsoCountryCodes.find(promise_params['country'])

    bank_account = @client.bank_accounts.create(
      user_id: user.id,
      bank_name: promise_params['bank_name'],
      account_name: promise_params['account_name'],
      routing_number: promise_params['routing_number'],
      account_number: promise_params['account_number'],
      account_type: promise_params['account_type'],
      holder_type: promise_params['holder_type'],
      country: country_for_bank.alpha3
    )

    direct_debit_agreement = promise_params["direct_debit_agreement"] == "1"

    PromiseAccount.create({
      user_id: current_user.id,
      bank_account_id: bank_account.id,
      direct_debit_agreement: direct_debit_agreement
    })
  end

  def set_promise_order_id(promise_order)
    if Rails.env.development?
      'dev_item_id' + promise_order.id.to_s
    elsif Rails.env.staging?
      'stag_item_id' + promise_order.id.to_s
    else
      promise_order.id
    end
  end
end
