module EmailHelper

  def get_image(image_path)
    attachments.inline[image_path] = open(image_path).read
    attachments[image_path].url
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
