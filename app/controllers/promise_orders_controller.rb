class PromiseOrdersController < ApplicationController

  def update
    promise_order = PromiseOrder.find_by_id(params[:id])
    product = promise_order.product
    set_promise_pay_instance
    create_item_in_promise(promise_order)

    redirect_to product_checkout_path(product_id: product.id, promise_order_id: promise_order.id)
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

  private

  def set_promise_pay_instance
    promise_pay_instance = PromisePayService.new
    @client = promise_pay_instance.client
  end

  def create_item_in_promise(promise_order)
    amount_in_cent = promise_order.amount * 100
    fee_ids = seller_add_fees(promise_order)

    item_ids = @client.items.find_all.map &:id

    if item_ids.include? promise_order.product_id
      item = @client.items.find(promise_order.product_id)
    else
      item = @client.items.create(
        id: promise_order.product_id,
        name: promise_order.product.name,
        amount: amount_in_cent, #amount in cent
        payment_type: 1, # 1=> Escrow
        buyer_id: promise_order.buyer.id,
        seller_id: promise_order.seller.id,
        fee_ids: fee_ids,
        description: promise_order.product.description
        # due_date: '22/04/2016' #not quite sure about this
      )
    end

    if item.present? && item.status["state"] == "pending"
      item.request_payment(id: item.id)
      if item.state == "payment_required"
        if promise_order.update_attributes({state: item.state})
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
    else
      redirect_to product_checkout_path(
        product_id: product.id,
        promise_order_id: promise_order.id
      ), :flash => { :alert => 'Your order cannot be placed.'}
    end
  end

  def seller_add_fees(promise_order)
    fee_id_collection = promise_order.promise_seller_fee_id

    fee_id_collection[:ach_fee] + ',' + fee_id_collection[:transaction_fee] +
      ',' + fee_id_collection[:end_user_fee]
  end
end
