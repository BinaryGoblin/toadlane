module EmailHelper

  def email_image_tag(user)
    # if user.asset(:small).split("/").include?("missing.png")
    #   if Rails.env == "development"
    #     attachments.inline[image] = File.read(Rails.root.join("app/assets/images/avatar/small/missing.png"))
    #     image_tag attachments.inline[image].url
    #   else
    #     image_tag "missing.png"
    #   end
    # else
    #   image_tag "#{user.asset(:small)}"
    # end
    if image.split("/").include?("missing.png")
      attachments.inline[image] = File.read(Rails.root.join("app/assets/images/avatar/small/missing.png"))
      image_tag attachments.inline[image].url
    else
      attachments.inline[image] = File.read(Rails.root.join("public#{image}"))
    end

    image_tag attachments.inline[image].url
  end
end
