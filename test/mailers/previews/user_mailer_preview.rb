# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def sales_order_notification_to_buyer
    order = FlyBuyOrder.first

    UserMailer.sales_order_notification_to_buyer(order)
  end

  def send_wire_instruction_notification_to_buyer
    order = FlyBuyOrder.first

    UserMailer.send_wire_instruction_notification_to_buyer(order)
  end

  def fly_buy_order_notification_to_buyer
    order = FlyBuyOrder.first

    UserMailer.fly_buy_order_notification_to_buyer(order)
  end

  def sales_order_notification_to_seller
    order = FlyBuyOrder.first
    UserMailer.sales_order_notification_to_seller(order)
  end

  def sales_order_notification_to_additional_seller
    order = FlyBuyOrder.first
    group = Group.first
    group_seller = GroupSeller.first

    UserMailer.sales_order_notification_to_additional_seller(order, group, group_seller)
  end

  def order_canceled_fund_not_sent
    order = FlyBuyOrder.first
    user = User.find(order.buyer_id)

    UserMailer.order_canceled_fund_not_sent(order, user)
  end

  def order_canceled_notification_to_seller
    stripe_order = StripeOrder.first
    UserMailer.order_canceled_notification_to_seller(stripe_order)
  end

  def refund_request_notification_to_seller
    stripe_order = StripeOrder.first
    UserMailer.refund_request_notification_to_seller(stripe_order)
  end

  def refund_request_accepted_notification_to_buyer
    stripe_order = StripeOrder.first
    UserMailer.refund_request_accepted_notification_to_buyer(stripe_order)
  end

  def refund_request_rejected_notification_to_buyer
    stripe_order = StripeOrder.first
    UserMailer.refund_request_rejected_notification_to_buyer(stripe_order)
  end

  def refund_request_canceled_notification_to_seller
    stripe_order = StripeOrder.first
    UserMailer.refund_request_canceled_notification_to_seller(stripe_order)
  end

  def send_confirmation_email
    product = Product.first
    user = User.first

    UserMailer.send_confirmation_email(user, product, nil)
  end

  def send_inspection_date_set_notification_to_seller
    order = InspectionDate.buyer_added.first.fly_buy_order

    UserMailer.send_inspection_date_set_notification_to_seller(order)
  end

  def send_inspection_date_set_notification_to_buyer
    order = InspectionDate.buyer_added.first.fly_buy_order

    UserMailer.send_inspection_date_set_notification_to_buyer(order)
  end

  def send_inspection_date_confirm_notification_to_buyer
    order = InspectionDate.buyer_added.first.fly_buy_order

    UserMailer.send_inspection_date_confirm_notification_to_buyer(order)
  end

  def send_armor_profile_created_notification
    user = User.first

    UserMailer.send_armor_profile_created_notification(user)
  end

  def send_funds_received_notification_to_seller
    order = FlyBuyOrder.first

    UserMailer.send_funds_received_notification_to_seller(order)
  end

  def send_transaction_settled_notification_to_buyer
    order = FlyBuyOrder.first

    UserMailer.send_transaction_settled_notification_to_buyer(order)
  end

  def send_routing_number_incorrect_notification
    user = User.first

    UserMailer.send_routing_number_incorrect_notification(user)
  end

  def send_payment_released_notification_to_buyer
    order = ArmorOrder.where.not(order_id: nil).first

    UserMailer.send_payment_released_notification_to_buyer(order)
  end

  def send_payment_released_notification_to_seller
    order = FlyBuyOrder.first

    UserMailer.send_payment_released_notification_to_seller(order)
  end

  def send_order_queued_notification_to_seller
    order = FlyBuyOrder.first

    UserMailer.send_order_queued_notification_to_seller(order)
  end

  def send_order_queued_notification_to_buyer
    order = FlyBuyOrder.first

    UserMailer.send_order_queued_notification_to_buyer(order)
  end

  def send_notification_for_fly_buy_profile
    fly_buy_profile = FlyBuyProfile.first
    address_id = Address.first.id

    UserMailer.send_notification_for_fly_buy_profile(fly_buy_profile, address_id)
  end

  def send_account_verified_notification_to_user
    fly_buy_profile = FlyBuyProfile.first

    UserMailer.send_account_verified_notification_to_user(fly_buy_profile)
  end

  def send_account_not_verified_yet_notification_to_user
    fly_buy_profile = FlyBuyProfile.first

    UserMailer.send_account_not_verified_yet_notification_to_user(fly_buy_profile)
  end

  def send_ssn_num_not_valid_notification_to_user
    fly_buy_profile = FlyBuyProfile.first

    UserMailer.send_ssn_num_not_valid_notification_to_user(fly_buy_profile)
  end

  def send_ein_num_not_valid_notification_to_user
    fly_buy_profile = FlyBuyProfile.first

    UserMailer.send_ein_num_not_valid_notification_to_user(fly_buy_profile)
  end

  def send_ssn_num_partially_valid_notification_to_user
    fly_buy_profile = FlyBuyProfile.first

    UserMailer.send_ssn_num_partially_valid_notification_to_user(fly_buy_profile)
  end

  def send_tin_num_partially_valid_notification_to_user
    fly_buy_profile = FlyBuyProfile.first

    UserMailer.send_tin_num_partially_valid_notification_to_user(fly_buy_profile)
  end

  def send_inspection_date_arriving_to_seller
    order = FlyBuyOrder.first
    days = 5

    UserMailer.send_inspection_date_arriving_to_seller(order, days)
  end

  def send_inspection_date_arriving_to_buyer
    order = FlyBuyOrder.first
    days = 5

    UserMailer.send_inspection_date_arriving_to_buyer(order, days)
  end

  def wire_instruction_notification_sent_to_seller
    order = FlyBuyOrder.first

    UserMailer.wire_instruction_notification_sent_to_seller(order)
  end

  # for additional_seller
  def send_account_marked_unverified_notification
    user = User.first

    UserMailer.send_account_marked_unverified_notification(user)
  end

  def send_account_marked_verified_notification
    user = User.first

    UserMailer.send_account_marked_verified_notification(user)
  end

  def send_added_as_additional_seller_notification
    product = Product.first
    owner = product.owner
    group_seller = GroupSeller.first
    additional_seller = User.first

    UserMailer.send_added_as_additional_seller_notification(owner, additional_seller, product, group_seller)
  end

  def send_additional_seller_accept_deal_to_owner
    product = Product.first
    group_seller = GroupSeller.first

    UserMailer.send_additional_seller_accept_deal_to_owner(group_seller, product)
  end

  def send_additional_seller_accept_deal_notification
    product = Product.first
    group_seller = GroupSeller.first

    UserMailer.send_additional_seller_accept_deal_notification(group_seller, product)
  end

  def send_additional_seller_reject_deal_to_owner
    product = Product.first
    group_seller = GroupSeller.first

    UserMailer.send_additional_seller_reject_deal_to_owner(group_seller, product)
  end

  def send_additional_seller_reject_deal_notification
    product = Product.first
    group_seller = GroupSeller.first

    UserMailer.send_additional_seller_reject_deal_notification(group_seller, product)
  end

  def send_group_created_notification_to_admin
    product = Product.first
    if Rails.env.development?
      admin_email = Rails.application.secrets['ADMIN_EMAIL_GROUP_VERIFICATION']
    else
      admin_email = ENV['ADMIN_EMAIL_GROUP_VERIFICATION']
    end

    UserMailer.send_group_created_notification_to_admin(product)
  end

  def send_group_marked_unverified_notification
    product = Product.first
    user = User.first

    UserMailer.send_group_marked_unverified_notification(product, user)
  end

  def send_group_marked_verified_notification
    product = Product.first
    user = User.first

    UserMailer.send_group_marked_verified_notification(product, user)
  end

  def release_payment_not_possible_notification_to_additional_seller
   fly_buy_order = FlyBuyOrder.first
   add_seller = User.first

   UserMailer.release_payment_not_possible_notification_to_additional_seller(fly_buy_order, add_seller)
  end

  def send_payment_release_to_additional_seller
    order = FlyBuyOrder.first
    additional_seller = User.first

    UserMailer.send_payment_release_to_additional_seller(order, additional_seller)
  end

  def notify_buyer_for_cancled_seller_payment
    order = FlyBuyOrder.first

    UserMailer.notify_buyer_for_cancled_seller_payment(order)
  end

  def notify_seller_for_cancled_additional_seller_payment
    order = FlyBuyOrder.first
    additional_seller = User.first

    UserMailer.notify_seller_for_cancled_additional_seller_payment(order, additional_seller)
  end

  def notify_buyer_for_cancled_order
    order = FlyBuyOrder.first

    UserMailer.notify_buyer_for_cancled_order(order)
  end

  def notify_buyer_for_placed_cancle_fly_buy_order
    order = FlyBuyOrder.first
    buyer = order.buyer

    UserMailer.notify_buyer_for_placed_cancle_fly_buy_order(order)
  end

  def notify_seller_and_additional_sellers_for_buyer_placed_cancle_fly_buy_order
    order = FlyBuyOrder.first

    UserMailer.notify_seller_and_additional_sellers_for_buyer_placed_cancle_fly_buy_order(order, [])
  end

  def send_transaction_refunded_notification_to_buyer
    order = FlyBuyOrder.first
    buyer = order.buyer

    UserMailer.send_transaction_refunded_notification_to_buyer(order)
  end

  def send_new_inspection_date_requested_notification
    order = FlyBuyOrder.first
    sender = order.buyer
    receiver = order.seller

    UserMailer.send_new_inspection_date_requested_notification(order, receiver, sender)
  end

  def send_new_inspection_date_approved_notification
    order = FlyBuyOrder.first
    sender = order.buyer
    receiver = order.seller

    UserMailer.send_new_inspection_date_approved_notification(order, receiver, sender)
  end

  def order_inspection_date_change_notification_to_admin
    order = FlyBuyOrder.first
    user = order.seller

    UserMailer.order_inspection_date_change_notification_to_admin(order, user)
  end
end