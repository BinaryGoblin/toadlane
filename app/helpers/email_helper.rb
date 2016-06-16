module EmailHelper

  def email_image_tag(image)
    if image.split("/").include?("missing.png")
      attachments.inline[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
    else
      attachments.inline[image] = File.read(Rails.root.join("public#{image}"))
    end

    image_tag attachments.inline[image].url
  end
end
