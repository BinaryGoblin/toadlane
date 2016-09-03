module EmailHelper
  include Rails.application.routes.url_helpers

  def get_image(image_path)
    attachments.inline[image_path] = open(image_path).read
    attachments[image_path].url
  rescue
    "http://staging-toad.s3-us-west-2.amazonaws.com/users/assets/000/000/031/small/missing.png"
  end

  def get_email_or_name(user)
    if user.name.present?
      user.name.titleize
    else
      user.email
    end
  end

  def get_amount_without_fees(order)
    order.unit_price * order.count.to_f
  end

  def get_amount_for_rebate(order)
    amount_without_fees = get_amount_without_fees(order)
    amount_without_fees * order.rebate / 100
  end
end
