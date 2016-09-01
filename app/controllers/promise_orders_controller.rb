class PromiseOrdersController < ApplicationController

  def update
    promise_order = PromiseOrder.find_by_id(params[:id])
    product = promise_order.product
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
end
