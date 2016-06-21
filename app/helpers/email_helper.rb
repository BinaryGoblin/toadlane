module EmailHelper

  def get_user_image(image_path)
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
end
