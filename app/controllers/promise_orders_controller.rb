class PromiseOrdersController < ApplicationController

  def update
    promise_order = PromiseOrder.find_by_id(params[:id])
    product = promise_order.product
    set_promise_pay_instance
    create_item_in_promise(product, promise_order)
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
          promise_order_id: promise_order.id,
          product_id: product.id
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

  def callbacks
    render nothing: true, status: 200
  end

  def complete_inspection
    promise_order = PromiseOrder.find_by_id(params["promise_order_id"])

    action_data = {
      "action" => "completeinspection",
      "confirm" => true
    }

    @client.orders(promise_order.seller_account_id).update(promise_order.order_id, action_data)
    promise_order.update_attribute(:inspection_complete, true)

    create_order_shipments(promise_order)

    release_fund_by_buyer(promise_order)

    redirect_to dashboard_orders_path, :flash => { :notice => "Product has been marked as inspected." }
  end

  private

  def set_promise_pay_instance
    promise_pay_instance = PromisePayService.new
    @client = promise_pay_instance.client
  end

  def create_item_in_promise(product, promise_order)
    amount_in_cent = promise_order.amount * 100
    fee_ids, seller_fee_amount = seller_add_fees(promise_order)

    item = @client.items.create(
      id: promise_order.id,
      name: product.name,
      amount: amount_in_cent, #amount in cent
      payment_type: 1, # 1=> Escrow
      buyer_id: promise_order.buyer.id,
      seller_id: promise_order.seller.id,
      fee_ids: fee_ids,
      description: product.description
      # due_date: '22/04/2016' #not quite sure about this
    )

    if item.present? && item.status["state"] == "pending"
      item.request_payment(id: item.id)
      amount_after_fee_to_seller = promise_order.amount - seller_fee_amount

      if promise_order.update_attributes(
            {
              status: item.state,
              promise_item_id: item.id,
              seller_charged_fee: seller_fee_amount,
              amount_after_fee_to_seller: amount_after_fee_to_seller
            })
        product.sold_out += promise_order.count
        product.save
        UserMailer.sales_order_notification_to_seller(promise_order).deliver_later
        UserMailer.sales_order_notification_to_buyer(promise_order).deliver_later
        NotificationCreator.new(promise_order).after_order_created
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

  def seller_add_fees(promise_order)
    amount = promise_order.amount
    fee_id_collection = promise_order.promise_seller_fee_id

    fee_ids = fee_id_collection[:ach_fee] + ',' +
              fee_id_collection[:transaction_fee] +
              ',' + fee_id_collection[:end_user_fee]
    # In promise we are saving fees in amount in cents even to percentage
    # # the fee_type_id distinguishes if the fee is fixed or percentage or others
    # # for details see https://reference.promisepay.com/#create-fee

    ach_fee_percent = @client.fees.find(fee_id_collection[:ach_fee]).amount / 100.00
    transaction_fee_percent = @client.fees.find(fee_id_collection[:transaction_fee]).amount / 100.00
    end_user_fee_percent = @client.fees.find(fee_id_collection[:end_user_fee]).amount / 100.00

    seller_fee_amount = amount * ach_fee_percent / 100 +
                          amount * transaction_fee_percent / 100 +
                          amount * end_user_fee_percent / 100

    [fee_ids, seller_fee_amount]
  end
end
