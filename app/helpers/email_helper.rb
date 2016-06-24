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
      user.name
    else
      user.email
    end
  end

  def get_amount_without_fees(stripe_order)
    stripe_order.unit_price * stripe_order.count
  end
end
