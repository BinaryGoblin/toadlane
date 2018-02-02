class FlyBuyOrdersController < ApplicationController
  #  creating order
  # # and making payment
  def place_order
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = fly_buy_order.product
    fly_buy_profile = current_user.fly_buy_profile

    if current_user.fly_buy_profile_account_added?
      FlyAndBuy::PlaceOrderJob.perform_later(current_user, fly_buy_order)

      redirect_to dashboard_order_path(fly_buy_order, type: 'fly_buy'), notice: 'Your order has been placed. Please check your inbox for wire instructions.'
    else
      if fly_buy_order.update_attribute(:status, 'processing')
        product.sold_out += fly_buy_order.count
        product.save

        session[:redirect_back] = product_checkout_path(product_id: product.id, fly_buy_order_id: fly_buy_order.id)
        return redirect_to dashboard_accounts_path, flash: { error: 'You must complete your fly & buy profile to placed your order.' }
      else
        flash[:notice] = 'Your order could not be placed.'
        redirect_to product_checkout_path(product_id: product.id, fly_buy_order_id: fly_buy_order.id)
      end
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
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])

    if fly_buy_order.update_attributes(inspection_complete: true, status: :placed)
      flash[:notice] = 'Order has been marked as inspected'
    else
      flash[:alert] = 'Could not be marked as inspected'
    end

    redirect_to dashboard_orders_path
  end

  def release_payment
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    Services::FlyAndBuy::ReleasePaymentToSeller.new(current_user, fly_buy_order).process
    fly_buy_order.reload

    if fly_buy_order.error_details.present?
      if fly_buy_order.error_details['en'] == 'You do not have sufficient balance for this transfer.'
        redirect_to dashboard_orders_path, flash: { alert: 'The funds are not yet received in escrow. Please wait.' }
      else
        redirect_to dashboard_orders_path, flash: { error: fly_buy_order.error_details['en'] }
      end
    else
      UserMailer.payment_released_processing_notification(fly_buy_order)
      flash[:notice] = 'Your payment has been released. If it is past bank cut off time funds will hit the sellers account tomorrow.'

      redirect_to dashboard_orders_path
    end
  end

  def release_payment_to_additional_sellers_not_possible
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])

    fly_buy_order.product.additional_sellers.each do |additional_seller|
      UserMailer.release_payment_not_possible_notification_to_additional_seller(fly_buy_order, additional_seller).deliver_later if !additional_seller.fly_buy_profile.present?|| !additional_seller.fly_buy_profile_account_added? || additional_seller.fly_buy_unverified_by_admin?
    end if fly_buy_order.seller_group.present?

    redirect_to dashboard_orders_path
  end

  def release_payment_to_additional_sellers
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    fly_buy_order.update_attribute(:status, :processing_fund_release_to_group)

    FlyAndBuy::ReleasePaymentToAdditionalSellersJob.perform_later(current_user, fly_buy_order)

    redirect_to dashboard_orders_path
  end

  def confirm_order_placed
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    product = fly_buy_order.product

    if current_user.fly_buy_profile.kba_questions.present? && params['fly_buy_profile'].present?
      Services::FlyAndBuy::AnswerKbaQuestions.new(current_user, current_user.fly_buy_profile, fly_buy_params).process

      redirect_to product_checkout_path(product_id: product.id, fly_buy_order_id: fly_buy_order.id)
    end
  end

  def resend_wire_instruction
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    UserMailer.send_wire_instruction_notification_to_buyer(fly_buy_order).deliver_later

    redirect_to dashboard_order_path(fly_buy_order, type: 'fly_buy'), notice: 'You have been emailed wire instructions!'
  end

  def cancel_transaction
    fly_buy_order = FlyBuyOrder.find_by_id(params[:fly_buy_order_id])
    FlyAndBuy::CancelOrderJob.perform_later(current_user, fly_buy_order)
    fly_buy_order.reload

    if fly_buy_order.error_details.present?
      flash[:cancel_trans_error] = fly_buy_order.error_details['en']
    else
      flash[:notice] = 'You order has been canceled.'
    end

    redirect_to dashboard_orders_path(type: 'fly_buy')
  end

  private

  def fly_buy_params
    params.require(:fly_buy_profile).permit!
  end
end
