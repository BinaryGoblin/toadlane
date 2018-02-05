class NotificationMailer < ApplicationMailer
  add_template_helper(EmailHelper)
  include ActionView::Helpers::NumberHelper

  def product_create_notification_email(product, user)
    @user = user
    @product = product
    mail to: @user.email, subject: "#{@product.name} just listed for sale!"
  end

  def request_create_notification_email(product, user)
    @user = user
    @product = product
    mail to: @user.email, subject: "#{@product.owner.name} wants to buy #{@product.name} from you!"
  end

  def offer_notification_email(offer, request)
    @offer = offer
    @offer_owner = @offer.owner
    @request = request
    @request_owner = @request.owner

    mail to: @request.owner.email, subject: "#{@request.owner.name} offered you #{@offer.name} for #{number_to_currency(@offer.unit_price)}/Unit"
  end

  def additional_seller_removed_notification_email(product, user, current_user, admins)
    @product = product
    @user = user
    @current_user = current_user
    @admins = admins

    mail to: @user.email, subject: "#{@current_user.name.titleize} removed you from a group"
  end

  def group_product_removed_notification_email(param_hash)
    @group = param_hash[:group]
    @product = param_hash[:product]
    @user = param_hash[:group_seller]
    @current_user = param_hash[:current_user]
    @admins = param_hash[:admins]

    mail to: @user.email, subject: "#{@product.name} has been deleted"
  end

  def group_removed_notification_email(param_hash)
    @group = param_hash[:group]
    @product = param_hash[:product]
    @user = param_hash[:group_seller]
    @current_user = param_hash[:current_user]
    @admins = param_hash[:admins]

    mail to: @user.email, subject: "#{@group} has been deleted"
  end

  def group_product_expired_notification_email(product, user, admins)
    @product = product
    @user = user
    @admins = admins

    mail to: @user.email, subject: "#{@product.name} has expired"
  end

  def product_expired_notification_to_owner(product)
    @product = product
    @owner = @product.owner

    mail to: @owner.email, subject: "#{@product.name} has expired"
  end
end
