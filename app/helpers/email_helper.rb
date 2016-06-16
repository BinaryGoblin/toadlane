module EmailHelper

  def email_image_tag(user)
    image_tag "#{user.asset(:small)}"
    # if user.asset(:small).split("/").include?("missing.png")
    #   if Rails.env == "development"
    #     binding.pry
    #     attachments.inline[image] = File.read(Rails.root.join("app/assets/images/avatar/small/missing.png"))
    #     image_tag attachments.inline[image].url
    #   else
    #     image_tag "missing.png"
    #   end
    # else
    #   image_tag "#{user.asset(:small)}"
    # end
  end
end
