class UserMailer < ApplicationMailer
  add_template_helper(EmailHelper)

  def sales_order_notification_to_seller(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @seller.email, subject: 'You have a sales order!!!'
  end

  def sales_order_notification_to_buyer(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @buyer.email, subject: 'Your order has been placed!!!'
  end

  def order_canceled_notification_to_seller(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has canceled an order!!!"
  end

  def refund_request_notification_to_seller(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has requested refund for an order!!!"
  end

  def refund_request_accepted_notification_to_buyer(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @buyer.email, subject: 'Your refund request has been accepted!!!'
  end

  def refund_request_rejected_notification_to_buyer(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @buyer.email, subject: 'Your refund request has been rejected!!!'
  end

  def refund_request_canceled_notification_to_seller(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has canceled a refund request!!!"
  end

  def send_confirmation_email(user, product = nil, armor_order = nil)
    @product = product
    @armor_order = armor_order
    @user = user

    mail to: @user.email, subject: "Confirm your email for Fly & Buy"
  end

  def send_inspection_date_set_notification_to_seller(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has requested to set inspection date"
  end

  def send_inspection_date_set_notification_to_buyer(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @buyer.email, subject: "#{@seller.name} has responded to inspection date that you set"
  end

  def send_inspection_date_confirm_notification_to_buyer(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @buyer.email, subject: "#{@seller.name} has confirmed the inspection date"
  end

  def send_armor_profile_created_notification(user)
    @user = user

    mail to: @user.email, subject: "Armor Profile Successfully Created"
  end

  def send_funds_received_notification_to_seller(order)
    @order = order
    @seller = order.seller

    mail to: @seller.email, subject: "Funds received in escrow"
  end

  def send_transaction_settled_notification_to_buyer(order)
    @order = order
    @buyer = order.buyer

    mail to: @buyer.email, subject: "Funds received in escrow"
  end

  def send_routing_number_incorrect_notification(user)
    @user = user

    mail to: @user.email, subject: "Invalid routing number supplied"
  end

  def send_payment_released_notification_to_buyer(order)
    @order = order
    @buyer = @order.buyer
    @seller = @order.seller

    mail to: @buyer.email, subject: "You have released payment for order #{@order.order_id}"
  end

  def send_payment_released_notification_to_seller(order)
    @order = order
    @seller = @order.seller
    @buyer = @order.buyer

    mail to: @seller.email, subject: "Payment released by #{@buyer.name} for order #{@order.id}"
  end


  def send_order_queued_notification_to_seller(order)
    @order = order
    @seller = order.seller
    @buyer = @order.buyer

    mail to: @seller.email, subject: "OrderId ##{@order.id} is queued"
  end

  def send_order_queued_notification_to_buyer(order)
    @order = order
    @seller = order.seller
    @buyer = @order.buyer

    mail to: @buyer.email, subject: "OrderId ##{@order.id} is queued"
  end

  def send_account_verified_notification_to_user(fly_buy_profile)
    @fly_buy_profile = fly_buy_profile
    @user = @fly_buy_profile.user

    mail to: @user.email, subject: "Fly & Buy account verified"
  end

  def send_account_not_verified_yet_notification_to_user(fly_buy_profile)
    @fly_buy_profile = fly_buy_profile
    @user = @fly_buy_profile.user

    mail to: @user.email, subject: "Fly & Buy account not verified yet"
  end

  def send_ssn_num_not_valid_notification_to_user(fly_buy_profile)
    @fly_buy_profile = fly_buy_profile
    @user = @fly_buy_profile.user

    mail to: @user.email, subject: "Invalid Social Security Number"
  end

  def send_ein_num_not_valid_notification_to_user(fly_buy_profile)
    @fly_buy_profile = fly_buy_profile
    @user = @fly_buy_profile.user

    mail to: @user.email, subject: "Invalid Employer Identification Number"
  end

  def send_ssn_num_partially_valid_notification_to_user(fly_buy_profile)
    @fly_buy_profile = fly_buy_profile
    @user = @fly_buy_profile.user

    mail to: @user.email, subject: "Social Security Number partially matched"
  end

  def send_tin_num_partially_valid_notification_to_user(fly_buy_profile)
    @fly_buy_profile = fly_buy_profile
    @user = @fly_buy_profile.user

    mail to: @user.email, subject: "Employer Identification Number partially matched"
  end

  def send_inspection_date_arriving_to_seller(order, days)
    @order = order
    @seller = @order.seller
    @days = days

    mail to: @seller.email, subject: "Inspection Date is arriving in #{@days} day/s"
  end

  def send_inspection_date_arriving_to_buyer(order, days)
    @order = order
    @buyer = @order.buyer
    @days = days

    mail to: @buyer.email, subject: "Inspection Date is arriving in #{@days} day/s"
  end

  def send_wire_instruction_notification_to_buyer(order)
    @order = order
    @buyer = @order.buyer
    attachments['fly_buy_wire_instructions.pdf'] = File.read('app/assets/pdfs/fly_buy_wire_instructions.pdf')

    mail to: @buyer.email, subject: "Reminder to send funds intro escrow"
  end

  def wire_instruction_notification_sent_to_seller(order)
    @order = order
    @seller = @order.seller

    mail to: @seller.email, subject: "Notification to buyer sent"
  end

  # for additional_seller
  def send_account_marked_unverified_notification(user)
    @user = user

    mail to: @user.email, subject: "Fly Buy account marked unverified"
  end

  def send_account_marked_verified_notification(user)
    @user = user

    mail to: @user.email, subject: "Fly Buy account marked verified"
  end

  def send_added_as_additional_seller_notification(owner, additional_seller, product, group_seller_id)
    @owner = owner
    @additional_seller = additional_seller
    @product = product
    @group_seller_id = group_seller_id

    mail to: @additional_seller.email, subject: "#{@owner.name.titleize} added you in a group"
  end

  def send_additional_seller_accept_deal_to_owner(invited_additional_seller, product)
    @product = product
    @owner = @product.owner
    @invited_additional_seller = invited_additional_seller

    mail to: @owner.email, subject: "#{@invited_additional_seller.name.titleize} has accepted the deal"
  end

  def send_additional_seller_accept_deal_notification(invited_additional_seller, product)
    @product = product
    @owner = @product.owner
    @invited_additional_seller = invited_additional_seller

    mail to: @invited_additional_seller.email, subject: "Additional Seller role accepted"
  end

  def send_additional_seller_reject_deal_to_owner(invited_additional_seller, product)
    @product = product
    @owner = @product.owner
    @invited_additional_seller = invited_additional_seller

    mail to: @owner.email, subject: "#{@invited_additional_seller.name.titleize} has rejected the deal"
  end

  def send_additional_seller_reject_deal_notification(invited_additional_seller, product)
    @product = product
    @owner = @product.owner
    @invited_additional_seller = invited_additional_seller

    mail to: @invited_additional_seller.email, subject: "Additional Seller role rejected"
  end

  def send_group_created_notification_to_admin(product)
    @product = product
    if Rails.env.development?
      admin_email = Rails.application.secrets['ADMIN_EMAIL_GROUP_VERIFICATION']
    else
      admin_email = ENV['ADMIN_EMAIL_GROUP_VERIFICATION']
    end

    mail to: admin_email, subject: "A new group has been created"
  end

  def send_group_marked_unverified_notification(product, user)
    @product = product
    @user = user

    mail to: @user.email, subject: "Group marked unverified"
  end

  def send_group_marked_verified_notification(product, user)
    @product = product
    @user = user

    mail to: @user.email, subject: "Group marked verified"
  end

  def release_payment_not_possible_notification_to_additional_seller(fly_buy_order, add_seller)
    @fly_buy_order = fly_buy_order
    @product = @fly_buy_order.product
    @group = @fly_buy_order.seller_group
    @add_seller = add_seller
    @fly_buy_profile = @add_seller.fly_buy_profile

    mail to: @add_seller.email, subject: "Release Payment not possible"
  end

  def send_payment_release_to_additional_seller(order, additional_seller)
    @order = order
    @additional_seller = additional_seller

    mail to: @additional_seller.email, subject: "Payment released by #{@order.seller.name} for order #{@order.id}"
  end

  def test
    mail to: "testemails@mailinator.com", cc: "jailalawat@gmail.com", subject: "Payment rel"
  end
end
