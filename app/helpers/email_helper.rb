module EmailHelper

  def email_image_tag(image)
    if image.split("/").include?("missing.png")
      if Rails.env == "development"
        attachments.inline[image] = File.read(Rails.root.join("app/assets/images/avatar/small/missing.png"))
        image_tag attachments.inline[image].url
      else
        image_tag "missing.png"
      end
    else
      attachments.inline[image] = File.read(Rails.root.join("public#{image}"))
      image_tag attachments.inline[image].url
    end
  end
end
