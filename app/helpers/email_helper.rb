module EmailHelper

  def get_user_image(image_path)
    attachments.inline[image_path] = open(image_path).read
    attachments[image_path].url
  end
end
